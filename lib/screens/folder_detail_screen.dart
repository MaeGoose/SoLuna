import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/memory.dart';
import '../models/memory_folder.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'memory_preview_screen.dart';

/// Shown when tapping a "Memory Collections" folder on Today: a plain
/// photo gallery grid. Tap a thumbnail to open the full preview. Filters
/// the shared sample data by folderId — swap for a real query once
/// Supabase is connected.
class FolderDetailScreen extends StatefulWidget {
  const FolderDetailScreen({super.key, required this.folder});

  final MemoryFolder folder;

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  late List<Memory> _memories =
      sampleMemories.where((m) => m.folderId == widget.folder.id).toList();

  void _toggleFavorite(int index) {
    setState(() {
      _memories[index] = _memories[index].copyWith(
        isFavorite: !_memories[index].isFavorite,
      );
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
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
              Text(widget.folder.title, style: textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text('${widget.folder.itemCount} items', style: textTheme.labelSmall),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: _memories.isEmpty
                    ? Center(
                        child: Text('Nothing saved here yet.', style: textTheme.bodyMedium),
                      )
                    : GridView.builder(
                        itemCount: _memories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                        ),
                        itemBuilder: (context, index) {
                          final memory = _memories[index];
                          return _GalleryThumbnail(
                            memory: memory,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MemoryPreviewScreen(
                                  memory: memory,
                                  onFavoriteToggled: () => _toggleFavorite(index),
                                ),
                              ),
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

class _GalleryThumbnail extends StatelessWidget {
  const _GalleryThumbnail({required this.memory, required this.onTap});

  final Memory memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.bgPeach],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          if (memory.isFavorite)
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(Icons.favorite, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }
}
