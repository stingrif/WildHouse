// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary:      AppColors.walnut,
      onPrimary:    AppColors.cream,
      secondary:    AppColors.oak,
      onSecondary:  AppColors.graphite,
      tertiary:     AppColors.moss,
      surface:      AppColors.surface,
      onSurface:    AppColors.textPrimary,
      error:        AppColors.error,
      background:   AppColors.background,
      onBackground: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Jost',

    // ── AppBar ──────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.graphite,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.graphite,
        letterSpacing: 0.5,
      ),
      centerTitle: false,
    ),

    // ── Text ─────────────────────────────────────────────────
    textTheme: const TextTheme(
      // Display — Cormorant (заголовки экранов)
      displayLarge:  TextStyle(fontFamily: 'Cormorant', fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.graphite, height: 1.1),
      displayMedium: TextStyle(fontFamily: 'Cormorant', fontSize: 38, fontWeight: FontWeight.w600, color: AppColors.graphite, height: 1.15),
      displaySmall:  TextStyle(fontFamily: 'Cormorant', fontSize: 30, fontWeight: FontWeight.w600, color: AppColors.graphite, height: 1.2),
      // Headline — Cormorant
      headlineLarge:  TextStyle(fontFamily: 'Cormorant', fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.graphite),
      headlineMedium: TextStyle(fontFamily: 'Cormorant', fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.graphite),
      headlineSmall:  TextStyle(fontFamily: 'Cormorant', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.graphite),
      // Title — Jost
      titleLarge:  TextStyle(fontFamily: 'Jost', fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.graphite),
      titleMedium: TextStyle(fontFamily: 'Jost', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.graphite),
      titleSmall:  TextStyle(fontFamily: 'Jost', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.graphite),
      // Body — Jost
      bodyLarge:  TextStyle(fontFamily: 'Jost', fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5),
      bodyMedium: TextStyle(fontFamily: 'Jost', fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5),
      bodySmall:  TextStyle(fontFamily: 'Jost', fontSize: 12, fontWeight: FontWeight.w300, color: AppColors.textSecondary, height: 1.4),
      // Label
      labelLarge:  TextStyle(fontFamily: 'Jost', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.2),
      labelMedium: TextStyle(fontFamily: 'Jost', fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.0),
      labelSmall:  TextStyle(fontFamily: 'Jost', fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.2),
    ),

    // ── Buttons ──────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.walnut,
        foregroundColor: AppColors.cream,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(fontFamily: 'Jost', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.walnut,
        side: const BorderSide(color: AppColors.walnut, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(fontFamily: 'Jost', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.walnut,
        textStyle: const TextStyle(fontFamily: 'Jost', fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // ── Input ────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.sand,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.sandDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.walnut, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(fontFamily: 'Jost', color: AppColors.textHint, fontSize: 14),
      labelStyle: const TextStyle(fontFamily: 'Jost', color: AppColors.textSecondary),
    ),

    // ── Card ─────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.sandDark, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    // ── Chip ─────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.sand,
      selectedColor: AppColors.oak,
      labelStyle: const TextStyle(fontFamily: 'Jost', fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // ── Divider ──────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.sandDark,
      thickness: 1,
      space: 1,
    ),

    // ── BottomNav ────────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.walnut,
      unselectedItemColor: AppColors.textHint,
      selectedLabelStyle: TextStyle(fontFamily: 'Jost', fontSize: 10, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontFamily: 'Jost', fontSize: 10),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // ── Snackbar ─────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.graphite,
      contentTextStyle: const TextStyle(fontFamily: 'Jost', color: AppColors.cream, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
