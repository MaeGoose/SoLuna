/// A named collection of memories, e.g. "First Meets" or "Concerts".
class MemoryFolder {
  const MemoryFolder({
    required this.id,
    required this.title,
    required this.itemCount,
  });

  final String id;
  final String title;
  final int itemCount;
}
