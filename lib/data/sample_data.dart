import '../models/couple_date.dart';

/// Placeholder data for the Couple Dates tab only — Memories/Folders are
/// wired to Supabase now (see MemoriesRepository), so their sample data
/// was removed from here.
final List<CoupleDate> sampleCoupleDates = [
  CoupleDate(
    id: 'd1',
    title: 'Simple Tea Date',
    date: DateTime(2024, 2, 14),
    tagNote: 'After a School Event!',
  ),
  CoupleDate(
    id: 'd2',
    title: 'Rainy Movie Night',
    date: DateTime(2024, 5, 3),
    tagNote: 'It poured the whole time',
  ),
  CoupleDate(
    id: 'd3',
    title: 'Beach Sunset',
    date: DateTime(2024, 7, 20),
    tagNote: 'Ice cream after',
  ),
];
