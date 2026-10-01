import 'dart:typed_data';

/// A single saved date/event, shown on the Couple Dates screens. Saved
/// to Supabase — see CoupleDatesRepository for the actual reads/writes.
class CoupleDate {
  const CoupleDate({
    required this.id,
    required this.title,
    required this.date,
    required this.tagNote,
    this.mediaUrl,
    this.localBytes,
  });

  final String id;
  final String title;
  final DateTime date;
  final String tagNote;

  /// Where the photo actually lives — a public Supabase Storage URL.
  /// Null shows PolaroidPhoto's gradient placeholder, same as a Memory
  /// with no photo.
  final String? mediaUrl;

  /// A photo picked this session but not uploaded yet. Not persisted.
  final Uint8List? localBytes;
}
