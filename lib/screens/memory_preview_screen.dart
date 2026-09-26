import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Full-size preview of a single memory, opened by tapping a thumbnail in
/// a folder's gallery grid.
class MemoryPreviewScreen extends StatefulWidget {
  const MemoryPreviewScreen({
    super.key,
    required this.memory,
    this.onFavoriteToggled,
  });

  final Memory memory;

  /// Lets the folder grid this was opened from stay in sync — called
  /// whenever the favorite is toggled here, in addition to this screen's
  /// own local state.
  final VoidCallback? onFavoriteToggled;

  @override
  State<MemoryPreviewScreen> createState() => _MemoryPreviewScreenState();
}

class _MemoryPreviewScreenState extends State<MemoryPreviewScreen> {
  late Memory _memory = widget.memory;

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
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _memory.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.bgPeach],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
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
