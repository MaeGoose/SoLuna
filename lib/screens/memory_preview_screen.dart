import 'package:flutter/material.dart';

import '../data/memories_repository.dart';
import '../models/memory.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/memory_photo.dart';

/// Full-size preview of a single memory, opened by tapping a thumbnail in
/// a folder's gallery grid, search results, or an On This Day card.
class MemoryPreviewScreen extends StatefulWidget {
  const MemoryPreviewScreen({
    super.key,
    required this.memory,
    this.onFavoriteToggled,
    this.onDeleted,
  });

  final Memory memory;

  /// Lets the screen this was opened from stay in sync — called whenever
  /// the favorite is toggled here, in addition to this screen's own
  /// local state.
  final VoidCallback? onFavoriteToggled;

  /// Called after the memory is actually deleted (row + photo), right
  /// before this screen pops itself — lets the caller drop it from
  /// whatever list it was showing.
  final VoidCallback? onDeleted;

  @override
  State<MemoryPreviewScreen> createState() => _MemoryPreviewScreenState();
}

class _MemoryPreviewScreenState extends State<MemoryPreviewScreen> {
  late Memory _memory = widget.memory;
  bool _isDeleting = false;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _dateLabel =>
      '${_months[_memory.date.month - 1]} ${_memory.date.day}, ${_memory.date.year}';

  void _toggleFavorite() {
    setState(() => _memory = _memory.copyWith(isFavorite: !_memory.isFavorite));
    widget.onFavoriteToggled?.call();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this memory?'),
        content: Text('"${_memory.title}" and its photo will be gone for good.'),
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

    setState(() => _isDeleting = true);
    try {
      await MemoriesRepository.deleteMemory(_memory);
      widget.onDeleted?.call();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t delete that. Try again.')),
      );
    }
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
                  const Spacer(),
                  IconButton(
                    onPressed: _isDeleting ? null : _toggleFavorite,
                    icon: Icon(
                      _memory.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.secondary,
                    ),
                  ),
                  IconButton(
                    onPressed: _isDeleting ? null : _confirmDelete,
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: MemoryPhoto(
                    mediaUrl: _memory.mediaUrl,
                    localBytes: _memory.localBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(_memory.title, style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(_dateLabel, style: textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
