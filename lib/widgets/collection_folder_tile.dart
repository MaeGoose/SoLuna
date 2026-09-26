import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One "Memory Collections" folder tile — a pink square icon, a title, and
/// an item count underneath.
class CollectionFolderTile extends StatelessWidget {
  const CollectionFolderTile({
    super.key,
    required this.title,
    required this.itemCount,
    required this.onTap,
  });

  final String title;
  final int itemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(fontSize: 13),
            ),
            Text('$itemCount items', style: textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
