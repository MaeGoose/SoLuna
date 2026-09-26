import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The shared bottom nav bar — Today / Dates / Add / Settings — used on
/// every screen.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<IconData> _icons = [
    Icons.calendar_today,
    Icons.favorite_border,
    Icons.add_circle_outline,
    Icons.settings_outlined,
  ];

  static const List<String> _labels = ['Today', 'Dates', 'Add', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderPink, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < _icons.length; i++)
              InkWell(
                onTap: () => onTap(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[i],
                        color: i == currentIndex ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: i == currentIndex ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
