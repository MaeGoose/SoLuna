import 'package:flutter/material.dart';

import '../data/memories_repository.dart';
import '../models/memory.dart';
import '../models/memory_folder.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/memory_thumbnail.dart';
import 'memory_preview_screen.dart';

/// Shown when tapping a "Memory Collections" folder on Today: a plain
/// photo gallery grid. Tap a thumbnail to open the full preview. Loads
/// this folder's memories from Supabase via MemoriesRepository.
///
/// Pops with `true` if anything changed that Today's folder tiles need
/// to know about (a memory deleted here changes this folder's item
/// count; deleting the folder itself obviously does too) — Today
/// refetches whenever this screen returns `true`.
class FolderDetailScreen extends StatefulWidget {
  const FolderDetailScreen({super.key, required this.folder});

  final MemoryFolder folder;

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  bool _isLoading = true;
  bool _isDeletingFolder = false;
  bool _changed = false;
  List<Memory> _memories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final memories = await MemoriesRepository.fetchMemories(folderId: widget.folder.id);
    if (!mounted) return;
    setState(() {
      _memories = memories;
      _isLoading = false;
    });
  }

  void _toggleFavorite(int index) {
    final memory = _memories[index];
    final updated = memory.copyWith(isFavorite: !memory.isFavorite);
    setState(() => _memories[index] = updated);
    MemoriesRepository.setFavorite(memoryId: memory.id, isFavorite: updated.isFavorite);
  }

  void _removeMemory(int index) {
    setState(() {
      _memories.removeAt(index);
      _changed = true;
    });
  }

  Future<void> _confirmDeleteFolder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this folder?'),
        content: Text(
          _memories.isEmpty
              ? '"${widget.folder.title}" will be gone for good.'
              : '"${widget.folder.title}" will be gone for good. The ${_memories.length} '
                  '${_memories.length == 1 ? 'memory' : 'memories'} inside stay saved, just unfiled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeletingFolder = true);
    try {
      await MemoriesRepository.deleteFolder(widget.folder.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeletingFolder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t delete that folder. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
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
                      onPressed: () => Navigator.pop(context, _changed),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _isDeletingFolder ? null : _confirmDeleteFolder,
                      icon: _isDeletingFolder
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline, color: AppColors.error),
                      tooltip: 'Delete folder',
                    ),
                  ],
                ),
                Text(widget.folder.title, style: textTheme.headlineLarge),
                const SizedBox(height: 4),
                Text('${_memories.length} items', style: textTheme.labelSmall),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _memories.isEmpty
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
                                return MemoryThumbnail(
                                  memory: memory,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MemoryPreviewScreen(
                                        memory: memory,
                                        onFavoriteToggled: () => _toggleFavorite(index),
                                        onDeleted: () => _removeMemory(index),
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
      ),
    );
  }
}
