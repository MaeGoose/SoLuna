import 'package:flutter/material.dart';

import '../data/memories_repository.dart';
import '../models/memory.dart';
import '../theme/app_spacing.dart';
import '../widgets/polaroid_photo.dart';

/// Screen 3 of 6 — the tap-and-hold polaroid collage. The rearrange
/// interaction from the design isn't wired up yet (it's just a static
/// Wrap for now) — see the README's known issues. Memories come from
/// Supabase now via MemoriesRepository.
class OnThisDayExpandedScreen extends StatefulWidget {
  const OnThisDayExpandedScreen({super.key});

  @override
  State<OnThisDayExpandedScreen> createState() => _OnThisDayExpandedScreenState();
}

class _OnThisDayExpandedScreenState extends State<OnThisDayExpandedScreen> {
  bool _isLoading = true;
  List<Memory> _memories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final memories = await MemoriesRepository.fetchMemories();
    final now = DateTime.now();
    final onThisDay = memories
        .where((m) => m.date.month == now.month && m.date.day == now.day)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (!mounted) return;
    setState(() {
      _memories = onThisDay;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to today'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('On this day!', style: textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _memories.isEmpty
                        ? Center(
                            child: Text('No memories from this day yet.', style: textTheme.bodyMedium),
                          )
                        : SingleChildScrollView(
                            child: Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.lg,
                              children: [
                                for (final memory in _memories)
                                  PolaroidPhoto(
                                    caption: '${memory.title} · ${memory.date.year}',
                                    mediaUrl: memory.mediaUrl,
                                    localBytes: memory.localBytes,
                                    width: 150,
                                  ),
                              ],
                            ),
                          ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '✨ Tap and hold any photo to rearrange your memory collage',
                style: textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
