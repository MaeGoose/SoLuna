/// A single saved date/event, shown on the Couple Dates screens.
class CoupleDate {
  const CoupleDate({
    required this.id,
    required this.title,
    required this.date,
    required this.tagNote,
  });

  final String id;
  final String title;
  final DateTime date;
  final String tagNote;
}
