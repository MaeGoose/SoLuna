import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/memory.dart';
import '../models/memory_folder.dart';

/// All the Supabase reads/writes behind the Today screen, folder
/// galleries, and Add Memory form. Pulled into one place because those
/// three screens share the same handful of queries — keeping them here
/// means there's exactly one place that knows the table/column names.
class MemoriesRepository {
  MemoriesRepository._();

  static SupabaseClient get _client => Supabase.instance.client;

  static const _photosBucket = 'memory-photos';

  /// Finds the couple row for the signed-in user, creating one (as
  /// user1, no partner yet) the first time they save anything — so
  /// folders/memories work solo, before a partner has joined via
  /// Settings' invite-code flow. If a partner joins later, whatever
  /// this account already saved stays right where it is.
  static Future<String> getOrCreateCoupleId() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in.');

    final existing = await _client
        .from('couples')
        .select('id')
        .or('user1_id.eq.$uid,user2_id.eq.$uid')
        .maybeSingle();
    if (existing != null) return existing['id'] as String;

    final created = await _client.from('couples').insert({'user1_id': uid}).select('id').single();
    return created['id'] as String;
  }

  static Future<List<MemoryFolder>> fetchFolders() async {
    final rows = await _client.from('memory_folders').select('id, title').order('created_at');
    return [for (final row in rows) MemoryFolder(id: row['id'] as String, title: row['title'] as String)];
  }

  static Future<MemoryFolder> createFolder({
    required String coupleId,
    required String title,
  }) async {
    final row = await _client
        .from('memory_folders')
        .insert({'couple_id': coupleId, 'title': title})
        .select('id, title')
        .single();
    return MemoryFolder(id: row['id'] as String, title: row['title'] as String);
  }

  /// All memories for the signed-in user's couple, or just the ones in
  /// [folderId] when given. RLS already scopes every row to couples the
  /// caller belongs to, so there's no need to pass a couple id here.
  static Future<List<Memory>> fetchMemories({String? folderId}) async {
    final rows = folderId != null
        ? await _client.from('memories').select().eq('folder_id', folderId).order('date', ascending: false)
        : await _client.from('memories').select().order('date', ascending: false);
    return [for (final row in rows) _memoryFromRow(row)];
  }

  static Memory _memoryFromRow(Map<String, dynamic> row) => Memory(
        id: row['id'] as String,
        title: row['title'] as String,
        date: DateTime.parse(row['date'] as String),
        isFavorite: row['is_favorite'] as bool? ?? false,
        folderId: row['folder_id'] as String?,
        mediaUrl: row['media_url'] as String?,
      );

  static Future<void> setFavorite({
    required String memoryId,
    required bool isFavorite,
  }) async {
    await _client.from('memories').update({'is_favorite': isFavorite}).eq('id', memoryId);
  }

  /// Uploads [photoBytes] to Storage under this couple's own folder, then
  /// inserts the memories row pointing at it. The couple-scoped path
  /// (`{coupleId}/...`) is what the storage.objects RLS policies check —
  /// see the SQL file for the "Couple members can upload/view/delete
  /// memory photos" policies.
  static Future<Memory> createMemory({
    required String coupleId,
    required String title,
    required DateTime date,
    String? folderId,
    required Uint8List photoBytes,
  }) async {
    final path = '$coupleId/${DateTime.now().millisecondsSinceEpoch}_${_randomSuffix()}.jpg';

    await _client.storage.from(_photosBucket).uploadBinary(
          path,
          photoBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    final mediaUrl = _client.storage.from(_photosBucket).getPublicUrl(path);

    final row = await _client
        .from('memories')
        .insert({
          'couple_id': coupleId,
          'folder_id': folderId,
          'title': title,
          'date': date.toIso8601String().split('T').first,
          'media_url': mediaUrl,
        })
        .select()
        .single();
    return _memoryFromRow(row);
  }

  static String _randomSuffix() {
    final rand = Random();
    return List.generate(6, (_) => rand.nextInt(36).toRadixString(36)).join();
  }

  /// Deletes the memories row and, best-effort, its photo in Storage.
  /// The row delete is what matters for the UI; if the storage remove
  /// fails (e.g. already gone) we swallow it rather than block on it —
  /// a leftover file isn't worth surfacing an error for a delete the
  /// person already confirmed.
  static Future<void> deleteMemory(Memory memory) async {
    await _client.from('memories').delete().eq('id', memory.id);
    final path = _storagePathFromPublicUrl(memory.mediaUrl);
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

  /// Deletes a folder. Memories inside it are NOT deleted — the
  /// memories.folder_id foreign key is ON DELETE SET NULL, so they just
  /// become unfiled (still visible via search / On This Day) rather than
  /// disappearing along with the folder.
  static Future<void> deleteFolder(String folderId) async {
    await _client.from('memory_folders').delete().eq('id', folderId);
  }
}
