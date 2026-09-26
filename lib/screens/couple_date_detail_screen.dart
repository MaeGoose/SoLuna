import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../theme/app_spacing.dart';
import '../widgets/polaroid_photo.dart';
import '../widgets/sticky_note_tag.dart';

/// Screen 5 of 6 — one date as a swipeable polaroid card with a dot
/// progress indicator and a sticky-note-style context tag.
class CoupleDateDetailScreen extends StatefulWidget {
  const CoupleDateDetailScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<CoupleDateDetailScreen> createState() => _CoupleDateDetailScreenState();
}

class _CoupleDateDetailScreenState extends State<CoupleDateDetailScreen> {
  late final _controller = PageController(initialPage: widget.initialIndex);
  late int _currentPage = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < sampleCoupleDates.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _currentPage
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFFE9D8CB),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Couple Dates!', style: textTheme.headlineLarge),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: sampleCoupleDates.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final date = sampleCoupleDates[index];
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PolaroidPhoto(caption: date.title, width: 220),
                          const SizedBox(height: AppSpacing.md),
                          StickyNoteTag(text: date.tagNote),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
