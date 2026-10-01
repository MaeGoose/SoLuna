import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/couple_date.dart';
import 'memories_repository.dart';

/// Reads/writes for Couple Dates. Reuses MemoriesRepository's
/// getOrCreateCoupleId() (same couple, same rule) and the same
/// `memory-photos` Storage bucket as memories — a date's photo is just
/// another photo for this couple, no reason to split it into a second
/// bucket with its own policies.
class CoupleDatesRepository {
  CoupleDatesRepository._();

  static SupabaseClient get _client => Supabase.instance.client;

  static const _photosBucket = 'memory-photos';

  static Future<List<CoupleDate>> fetchDates() async {
    final rows = await _client.from('couple_dates').select().order('date', ascending: false);
    return [for (final row in rows) _dateFromRow(row)];
  }

  static CoupleDate _dateFromRow(Map<String, dynamic> row) => CoupleDate(
        id: row['id'] as String,
        title: row['title'] as String,
        date: DateTime.parse(row['date'] as String),
        tagNote: (row['tag_note'] as String?) ?? '',
        mediaUrl: row['media_url'] as String?,
      );

  static Future<CoupleDate> createDate({
    required String title,
    required DateTime date,
    String? tagNote,
    Uint8List? photoBytes,
  }) async {
    final coupleId = await MemoriesRepository.getOrCreateCoupleId();

    String? mediaUrl;
    if (photoBytes != null) {
      final path = '$coupleId/${DateTime.now().millisecondsSinceEpoch}_${_randomSuffix()}.jpg';
      await _client.storage.from(_photosBucket).uploadBinary(
            path,
            photoBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      mediaUrl = _client.storage.from(_photosBucket).getPublicUrl(path);
    }

    final row = await _client
        .from('couple_dates')
        .insert({
          'couple_id': coupleId,
          'title': title,
          'date': date.toIso8601String().split('T').first,
          'tag_note': tagNote,
          'media_url': mediaUrl,
        })
        .select()
        .single();
    return _dateFromRow(row);
  }

  /// Deletes the row and, best-effort, its photo in Storage — same
  /// "don't block the delete on a storage cleanup failure" approach as
  /// MemoriesRepository.deleteMemory.
  static Future<void> deleteDate(CoupleDate date) async {
    await _client.from('couple_dates').delete().eq('id', date.id);
    final path = _storagePathFromPublicUrl(date.mediaUrl);
    if (path != null) {
      try {
        await _client.storage.from(_photosBucket).remove([path]);
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
