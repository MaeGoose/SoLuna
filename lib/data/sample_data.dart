import '../models/couple_date.dart';
import '../models/memory.dart';
import '../models/memory_folder.dart';

/// Placeholder data so every screen has something to show before Supabase
/// is connected. Swap this out for real fetched data later — nothing else
/// in the screens should need to change, since they only take these types
/// as data, never reach into this file directly for logic.
final List<Memory> sampleMemories = [
  Memory(
    id: 'm1',
    title: 'School Funnies',
    date: DateTime(2023, 10, 24),
    isFavorite: true,
    folderId: 'f1',
  ),
  Memory(id: 'm2', title: 'Coffee Shop Chat', date: DateTime(2021, 9, 5), folderId: 'f1'),
  Memory(id: 'm3', title: 'Napkin Doodle', date: DateTime(2022, 1, 14), folderId: 'f2'),
  Memory(id: 'm4', title: 'Movie Night', date: DateTime(2024, 3, 2), folderId: 'f2'),
  Memory(id: 'm5', title: 'Summer Concert', date: DateTime(2023, 7, 8), folderId: 'f3'),
  Memory(id: 'm6', title: 'Beach Day', date: DateTime(2021, 9, 18), folderId: 'f3'),
  Memory(id: 'm7', title: 'Weekend Trip', date: DateTime(2022, 6, 12)),
];

final List<MemoryFolder> sampleFolders = [
  MemoryFolder(id: 'f1', title: 'First Meets', itemCount: 14),
  MemoryFolder(id: 'f2', title: 'Sweet Notes', itemCount: 42),
  MemoryFolder(id: 'f3', title: 'Concerts', itemCount: 12),
];

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
