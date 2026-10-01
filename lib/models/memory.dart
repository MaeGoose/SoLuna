import 'dart:typed_data';

/// A single saved photo memory. Saved to Supabase — see
/// MemoriesRepository for the actual reads/writes.
class Memory {
  const Memory({
    required this.id,
    required this.title,
    required this.date,
    this.isFavorite = false,
    this.folderId,
    this.mediaUrl,
    this.localBytes,
  });

  final String id;
  final String title;
  final DateTime date;
  final bool isFavorite;

  /// Which "Memory Collections" folder this belongs to, if any. Null for
  /// memories (like the Today feature) that aren't filed into a folder.
  final String? folderId;

  /// Where the photo actually lives — a public Supabase Storage URL.
  final String? mediaUrl;

  /// A photo picked this session but not uploaded yet — shown immediately
  /// via MemoryPhoto while createMemory() is still uploading it. Not
  /// persisted; once the upload finishes the real [mediaUrl] takes over.
  final Uint8List? localBytes;

  Memory copyWith({bool? isFavorite}) {
    return Memory(
      id: id,
      title: title,
      date: date,
      isFavorite: isFavorite ?? this.isFavorite,
      folderId: folderId,
      mediaUrl: mediaUrl,
      localBytes: localBytes,
    );
  }
}
