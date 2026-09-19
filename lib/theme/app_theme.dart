import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// The whole SoLuna theme, assembled once and handed to MaterialApp.
/// Never hardcode a color or a font size outside this file — reach for
/// Theme.of(context) instead, everywhere else.
final ThemeData soLunaTheme = ThemeData(
  useMaterial3: true,
  colorScheme: soLunaColorScheme,
  scaffoldBackgroundColor: AppColors.bgBlush,
  textTheme: TextTheme(
    // Display — hero greetings like "On this day!" / screen titles like
    // "Create New Account".
    headlineLarge: GoogleFonts.caveat(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    ),
    // Heading — card and section titles.
    headlineSmall: GoogleFonts.quicksand(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    // Body — normal text, dates.
    bodyMedium: GoogleFonts.quicksand(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    ),
    // Label — uppercase field labels.
    labelLarge: GoogleFonts.quicksand(
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: AppColors.textMuted,
    ),
    // Caption — timestamps, item counts, helper text.
    labelSmall: GoogleFonts.quicksand(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderPink, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderPink, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.75),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
);
