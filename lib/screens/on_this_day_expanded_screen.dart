import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../theme/app_spacing.dart';
import '../widgets/polaroid_photo.dart';

/// Screen 3 of 6 — the tap-and-hold polaroid collage. The rearrange
/// interaction from the design isn't wired up yet (it's just a static
/// Wrap for now) — see the README's known issues.
class OnThisDayExpandedScreen extends StatelessWidget {
  const OnThisDayExpandedScreen({super.key});

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
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.lg,
                    children: [
                      for (final memory in sampleMemories)
                        PolaroidPhoto(
                          caption: memory.title,
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
