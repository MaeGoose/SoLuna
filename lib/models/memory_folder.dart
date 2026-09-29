/// A named collection of memories, e.g. "First Meets" or "Concerts".
/// Item count isn't stored here — it's computed live from sampleMemories
/// wherever it's shown, so it can never drift out of sync.
class MemoryFolder {
  const MemoryFolder({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}
