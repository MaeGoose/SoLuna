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
  });

  final String id;
  final String title;
  final DateTime date;
  final bool isFavorite;

  /// Which "Memory Collections" folder this belongs to, if any. Null for
  /// memories (like the Today feature) that aren't filed into a folder.
  final String? folderId;

  Memory copyWith({bool? isFavorite}) {
    return Memory(
      id: id,
      title: title,
      date: date,
      isFavorite: isFavorite ?? this.isFavorite,
      folderId: folderId,
    );
  }
}
