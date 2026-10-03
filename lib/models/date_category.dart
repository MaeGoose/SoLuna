/// A named group of saved dates, e.g. "School Dates" or "Resto Dates" —
/// the Couple Dates equivalent of MemoryFolder. Item count and cover
/// photo aren't stored here — computed live from whatever dates were
/// fetched wherever this is shown.
class DateCategory {
  const DateCategory({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}
