/// A single saved date/event, shown on the Couple Dates screens. Saved
/// to Supabase — see CoupleDatesRepository for the actual reads/writes.
/// Can have any number of photos (including zero), stored in the
/// date_photos table — not a single media_url anymore.
class CoupleDate {
  const CoupleDate({
    required this.id,
    required this.title,
    required this.date,
    required this.tagNote,
    this.categoryId,
    this.photoUrls = const [],
  });

  final String id;
  final String title;
  final DateTime date;
  final String tagNote;
  final String? categoryId;
  final List<String> photoUrls;

  CoupleDate copyWith({List<String>? photoUrls}) {
    return CoupleDate(
      id: id,
      title: title,
      date: date,
      tagNote: tagNote,
      categoryId: categoryId,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }
}
