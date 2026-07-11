import 'package:flutter/material.dart';

/// Premium design color tokens for Quran Companion.
///
/// Design Inspiration:
/// • Apple Human Interface Guidelines (iOS 26)
/// • shadcn/ui
/// • Linear
/// • Notion
/// • Apple Books
///
/// Golden Rules:
/// - Avoid Material 3 tinted surfaces.
/// - Use soft surface separation.
/// - Borders should be barely visible.
/// - Prioritize typography over color.
/// - Create a calm reading experience.
class AppColors {
  AppColors._();

  // ===========================================================================
  // Light Theme
  // ===========================================================================

  /// Main application background
  static const Color lightBackground = Color(0xFFFAF9F6);

  /// Primary cards
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Secondary cards / grouped sections
  static const Color lightSurfaceSecondary = Color(0xFFF8F7F4);

  /// Main brand color
  static const Color lightPrimary = Color(0xFF1E5B4F);

  /// Less emphasized primary
  static const Color lightPrimaryMuted = Color(0xFF4F7D73);

  /// Accent for milestones, highlights and premium elements
  static const Color lightAccent = Color(0xFFB08D57);

  /// Main text
  static const Color lightTextPrimary = Color(0xFF1C1E21);

  /// Secondary text
  static const Color lightTextSecondary = Color(0xFF6E7278);

  /// Disabled / hint text
  static const Color lightTextTertiary = Color(0xFF9AA0A6);

  /// Extremely soft borders
  static const Color lightBorder = Color(0xFFF3F2EF);

  /// Divider color
  static const Color lightDivider = Color(0xFFF0EFEB);

  // ===========================================================================
  // Dark Theme
  // ===========================================================================

  /// Main background
  static const Color darkBackground = Color(0xFF0E1013);

  /// Cards
  static const Color darkSurface = Color(0xFF16191D);

  /// Secondary cards
  static const Color darkSurfaceSecondary = Color(0xFF1B2025);

  /// Brand color
  static const Color darkPrimary = Color(0xFF72B4A3);

  /// Muted brand color
  static const Color darkPrimaryMuted = Color(0xFF5B9084);

  /// Accent
  static const Color darkAccent = Color(0xFFD8B67A);

  /// Main text
  static const Color darkTextPrimary = Color(0xFFF6F7F8);

  /// Secondary text
  static const Color darkTextSecondary = Color(0xFFBAC1C9);

  /// Disabled / hint text
  static const Color darkTextTertiary = Color(0xFF7E8793);

  /// Very subtle borders
  static const Color darkBorder = Color(0xFF20242A);

  /// Divider
  static const Color darkDivider = Color(0xFF252A30);

  // ===========================================================================
  // AMOLED Theme
  // ===========================================================================

  static const Color amoledBackground = Color(0xFF000000);

  static const Color amoledSurface = Color(0xFF080808);

  static const Color amoledSurfaceSecondary = Color(0xFF0D0D0D);

  static const Color amoledBorder = Color(0xFF101010);

  static const Color amoledDivider = Color(0xFF151515);

  // ===========================================================================
  // Status Colors
  // ===========================================================================

  static const Color success = Color(0xFF2E7D5A);

  static const Color warning = Color(0xFFD99A2B);

  static const Color error = Color(0xFFD14343);

  static const Color info = Color(0xFF4A90E2);

  // ===========================================================================
  // Overlay
  // ===========================================================================

  static const Color scrim = Color(0x66000000);

  static const Color transparent = Colors.transparent;

  // ===========================================================================
  // Misc
  // ===========================================================================

  /// Selected verse highlight
  static const Color verseHighlight = Color(0xFFF3F8F6);

  /// Selected verse highlight (Dark)
  static const Color darkVerseHighlight = Color(0xFF1A2825);

  /// Audio playing highlight
  static const Color playingHighlight = Color(0xFFEAF5F1);

  /// Audio playing highlight (Dark)
  static const Color darkPlayingHighlight = Color(0xFF1B322C);

  /// Goal completed
  static const Color goalCompleted = Color(0xFF4CAF50);

  /// Streak color
  static const Color streak = Color(0xFFFFA726);

  /// Favorite
  static const Color favorite = Color(0xFFE53935);

  /// Bookmark
  static const Color bookmark = Color(0xFFB08D57);
}