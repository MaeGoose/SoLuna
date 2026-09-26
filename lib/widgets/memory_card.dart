import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The featured "on this day" memory card: a photo placeholder, a title,
/// a relative date, and a favorite toggle.
class MemoryCard extends StatelessWidget {
  const MemoryCard({
    super.key,
    required this.memory,
    required this.onFavoriteTap,
  });

  final Memory memory;
  final VoidCallback onFavoriteTap;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _dateLabel {
    final formatted = '${_months[memory.date.month - 1]} ${memory.date.day}, ${memory.date.year}';
    final years = DateTime.now().year - memory.date.year;
    if (years <= 0) return formatted;
    return '$formatted · $years year${years == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.bgPeach],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(memory.title, style: textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(_dateLabel, style: textTheme.labelSmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFavoriteTap,
                  icon: Icon(
                    memory.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
