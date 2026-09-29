import 'dart:typed_data';

/// A single saved photo/video memory. Sample data only for now — nothing
/// here is persisted or fetched from a backend yet (see the project README
/// for the Supabase plan).
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

  /// Where the real photo lives (Supabase Storage, once that's wired up).
  /// Null for now — every screen falls back to a gradient placeholder
  /// via MemoryPhoto until this is actually set.
  final String? mediaUrl;

  /// A photo picked this session but not uploaded anywhere yet — shown
  /// immediately via MemoryPhoto, but gone on restart since there's
  /// nowhere durable to put it until Supabase Storage exists. Once
  /// uploading is wired up, this gets replaced by a real [mediaUrl] and
  /// can be dropped.
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
