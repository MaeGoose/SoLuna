import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The two button looks used across SoLuna: a yellow primary CTA
/// ("Sign up") and a green secondary action ("View Map").
enum AppButtonStyle { primary, secondary }

/// A single button component used on every form and CTA in the app.
/// Takes data and a callback only — it never knows what tapping it does.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = style == AppButtonStyle.primary;
    final Color background = isPrimary ? AppColors.accent : AppColors.primary;
    final Color foreground = isPrimary ? const Color(0xFF4A3620) : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontSize: 15, color: foreground),
        ),
      ),
    );
  }
}
