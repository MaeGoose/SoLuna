/// A named collection of memories, e.g. "First Meets" or "Concerts".
/// Item count isn't stored here — it's computed live from whatever
/// memories were fetched wherever this is shown, so it can never drift
/// out of sync.
class MemoryFolder {
  const MemoryFolder({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}
