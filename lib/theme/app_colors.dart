import 'package:flutter/material.dart';

/// Raw brand colors, straight from the design system palette.
/// Material's ColorScheme only has room for a handful of named roles, so
/// bespoke pieces (the yellow CTA, the pink input border, the muted
/// caption color) live here and get referenced directly by widgets.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2B825D);
  static const Color secondary = Color(0xFFFCA1C2);
  static const Color accent = Color(0xFFFFD066);
  static const Color bgBlush = Color(0xFFFCE6F1);
  static const Color bgPeach = Color(0xFFF4E0C9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color borderPink = Color(0xFFEFA9C5);
  static const Color text = Color(0xFF4A3644);
  static const Color textMuted = Color(0xFFA38E9A);
  static const Color error = Color(0xFFD65A6E);
}

/// Material 3 ColorScheme, generated from the brand primary so every
/// built-in widget (buttons, dialogs, app bars) gets a contrast-checked
/// palette for free. Light only for v1 — see the design system doc for
/// the contrast numbers this was checked against.
final ColorScheme soLunaColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  brightness: Brightness.light,
).copyWith(
  secondary: AppColors.secondary,
  surface: AppColors.surface,
  error: AppColors.error,
  onSurface: AppColors.text,
);
