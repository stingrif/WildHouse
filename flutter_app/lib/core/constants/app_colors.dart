// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

/// Wild House brand palette
abstract class AppColors {
  // Primary palette
  static const Color oak      = Color(0xFFD6B48A);
  static const Color walnut   = Color(0xFF8B5E3C);
  static const Color sand     = Color(0xFFF4EBDD);
  static const Color graphite = Color(0xFF3C3C3C);
  static const Color moss     = Color(0xFF6C7A5A);

  // Extended
  static const Color oakLight    = Color(0xFFEDD9BE);
  static const Color walnutDark  = Color(0xFF5A3A22);
  static const Color sandDark    = Color(0xFFE8D8C4);
  static const Color graphiteSoft= Color(0xFF5A5A5A);
  static const Color cream       = Color(0xFFFAF7F3);

  // Semantic
  static const Color success = Color(0xFF4CAF6A);
  static const Color error   = Color(0xFFD94F3D);
  static const Color warning = Color(0xFFE5973A);
  static const Color info    = Color(0xFF4A90D9);

  // Background / surface
  static const Color background = cream;
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color surfaceAlt  = sand;

  // Text
  static const Color textPrimary   = graphite;
  static const Color textSecondary = graphiteSoft;
  static const Color textHint      = Color(0xFF9E9E9E);
  static const Color textOnDark    = Color(0xFFFAF7F3);

  // Overlays
  static const Color overlayDark  = Color(0x80000000);
  static const Color overlayLight = Color(0x40FFFFFF);

  // AR-специфичные
  static const Color arAccent  = oak;
  static const Color arOverlay = Color(0xCC1A1A1A);
}
