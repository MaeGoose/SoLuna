import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A polaroid-style photo card: a placeholder photo square with a
/// handwritten-font caption underneath, used on Couple Date Detail and
/// On This Day Expanded.
class PolaroidPhoto extends StatelessWidget {
  const PolaroidPhoto({
    super.key,
    required this.caption,
    this.width = 160,
  });

  final String caption;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.bgPeach, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 17),
          ),
        ],
      ),
    );
  }
}
