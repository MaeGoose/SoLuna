import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/couple_date.dart';
import '../models/date_category.dart';
import 'memories_repository.dart';

/// Reads/writes for Couple Dates. Reuses MemoriesRepository's
/// getOrCreateCoupleId() (same couple, same rule) and the same
/// `memory-photos` Storage bucket as memories — a date's photos are
/// just more photos for this couple, no reason to split them into a
/// second bucket with its own policies.
///
/// Each date can have any number of photos, held in the date_photos
/// table (one row per photo, FK'd to couple_dates with ON DELETE
/// CASCADE) rather than a single column on couple_dates itself.
class CoupleDatesRepository {
  CoupleDatesRepository._();

  static SupabaseClient get _client => Supabase.instance.client;

  static const _photosBucket = 'memory-photos';

  /// All dates for the couple, or just the ones in [categoryId] when
  /// given. Mirrors MemoriesRepository.fetchMemories' folderId param.
  static Future<List<CoupleDate>> fetchDates({String? categoryId}) async {
    final rows = categoryId != null
        ? await _client
            .from('couple_dates')
            .select('*, date_photos(media_url)')
            .eq('category_id', categoryId)
            .order('date', ascending: false)
        : await _client
            .from('couple_dates')
            .select('*, date_photos(media_url)')
            .order('date', ascending: false);
    return [for (final row in rows) _dateFromRow(row)];
  }

  static CoupleDate _dateFromRow(Map<String, dynamic> row) {
    final photoRows = (row['date_photos'] as List?) ?? const [];
    return CoupleDate(
      id: row['id'] as String,
      title: row['title'] as String,
      date: DateTime.parse(row['date'] as String),
      tagNote: (row['tag_note'] as String?) ?? '',
      categoryId: row['category_id'] as String?,
      photoUrls: [for (final p in photoRows) p['media_url'] as String],
    );
  }

  static Future<List<DateCategory>> fetchCategories() async {
    final rows = await _client.from('date_categories').select('id, title').order('created_at');
    return [for (final row in rows) DateCategory(id: row['id'] as String, title: row['title'] as String)];
  }

  static Future<DateCategory> createCategory({
    required String coupleId,
    required String title,
  }) async {
    final row = await _client
        .from('date_categories')
        .insert({'couple_id': coupleId, 'title': title})
        .select('id, title')
        .single();
    return DateCategory(id: row['id'] as String, title: row['title'] as String);
  }

  /// Deletes a category. Dates inside it are NOT deleted — category_id
  /// is ON DELETE SET NULL, so they just become uncategorized (still
  /// reachable via search) rather than disappearing.
  static Future<void> deleteCategory(String categoryId) async {
    await _client.from('date_categories').delete().eq('id', categoryId);
  }

  static Future<CoupleDate> createDate({
    required String title,
    required DateTime date,
    String? tagNote,
    String? categoryId,
    List<Uint8List> photos = const [],
  }) async {
    final coupleId = await MemoriesRepository.getOrCreateCoupleId();

    final row = await _client
        .from('couple_dates')
        .insert({
          'couple_id': coupleId,
          'category_id': categoryId,
          'title': title,
          'date': date.toIso8601String().split('T').first,
          'tag_note': tagNote,
        })
        .select()
        .single();
    final dateId = row['id'] as String;

    final photoUrls = <String>[];
    for (final bytes in photos) {
      photoUrls.add(await _uploadPhoto(coupleId: coupleId, dateId: dateId, bytes: bytes));
    }

    return CoupleDate(
      id: dateId,
      title: row['title'] as String,
      date: DateTime.parse(row['date'] as String),
      tagNote: (row['tag_note'] as String?) ?? '',
      categoryId: categoryId,
      photoUrls: photoUrls,
    );
  }

  /// Adds one more photo to a date that already exists — the "add more
  /// photos" action from the detail screen, not just at creation time.
  static Future<String> addPhotoToDate({
    required String dateId,
    required Uint8List photoBytes,
  }) async {
    final coupleId = await MemoriesRepository.getOrCreateCoupleId();
    return _uploadPhoto(coupleId: coupleId, dateId: dateId, bytes: photoBytes);
  }

  static Future<String> _uploadPhoto({
    required String coupleId,
    required String dateId,
    required Uint8List bytes,
  }) async {
    final path = '$coupleId/${DateTime.now().millisecondsSinceEpoch}_${_randomSuffix()}.jpg';
    await _client.storage.from(_photosBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    final url = _client.storage.from(_photosBucket).getPublicUrl(path);
    await _client.from('date_photos').insert({'date_id': dateId, 'media_url': url});
    return url;
  }

  /// Removes one photo from a date (not the whole date).
  static Future<void> deletePhoto({required String dateId, required String mediaUrl}) async {
    await _client.from('date_photos').delete().eq('date_id', dateId).eq('media_url', mediaUrl);
    final path = _storagePathFromPublicUrl(mediaUrl);
    if (path != null) {
      try {
        await _client.storage.from(_photosBucket).remove([path]);
      } catch (_) {
        // Row's already gone either way.
      }
    }
  }

  /// Deletes the whole date. date_photos rows cascade-delete with it;
  /// their Storage files are cleaned up here, best-effort.
  static Future<void> deleteDate(CoupleDate date) async {
    await _client.from('couple_dates').delete().eq('id', date.id);
    final paths = date.photoUrls
        .map(_storagePathFromPublicUrl)
        .whereType<String>()
        .toList();
    if (paths.isNotEmpty) {
      try {
        await _client.storage.from(_photosBucket).remove(paths);
      } catch (_) {
        // Row's already gone either way.
      }
    }
  }

  static String? _storagePathFromPublicUrl(String? url) {
    if (url == null) return null;
    final marker = '/$_photosBucket/';
    final index = url.indexOf(marker);
    if (index == -1) return null;
    return url.substring(index + marker.length);
  }

  static String _randomSuffix() {
    final rand = Random();
    return List.generate(6, (_) => rand.nextInt(36).toRadixString(36)).join();
  }
}
