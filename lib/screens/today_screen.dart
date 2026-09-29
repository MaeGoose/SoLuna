import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_search_field.dart';
import '../widgets/avatar_stack.dart';
import '../widgets/collection_folder_tile.dart';
import '../widgets/memory_card.dart';
import 'folder_detail_screen.dart';
import 'on_this_day_expanded_screen.dart';

/// Screen 2 of 6 — the Today / "On This Day" tab. Owns its own copy of the
/// featured memory locally just so the favorite toggle has something to
/// flip; a real version would lift this to wherever fetched data lives.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late var _featuredMemory = sampleMemories.first;

  void _toggleFavorite() {
    setState(() {
      _featuredMemory = _featuredMemory.copyWith(isFavorite: !_featuredMemory.isFavorite);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: AppSearchField()),
                const SizedBox(width: AppSpacing.sm),
                AvatarStack(
                  avatarLabels: const ['J', 'A'],
                  onFavoriteTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('On this day!', style: textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OnThisDayExpandedScreen()),
              ),
              child: MemoryCard(memory: _featuredMemory, onFavoriteTap: _toggleFavorite),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Memory Collections', style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final folder in sampleFolders) ...[
                    CollectionFolderTile(
                      title: folder.title,
                      itemCount: sampleMemories
                          .where((m) => m.folderId == folder.id)
                          .length,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FolderDetailScreen(folder: folder)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
