import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography design tokens.
class AppTypography {
  AppTypography._();

  static TextStyle display(BuildContext context) => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      );

  static TextStyle headline(BuildContext context) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      );

  static TextStyle title(BuildContext context) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );

  static TextStyle subtitle(BuildContext context) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle small(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle arabic({
    required double fontSize,
    Color? color,
  }) =>
      GoogleFonts.notoNaskhArabic(
        fontSize: fontSize,
        height: 2.0,
        color: color,
      );

  static TextStyle bangla({
    required double fontSize,
    Color? color,
  }) =>
      GoogleFonts.notoSansBengali(
        fontSize: fontSize,
        height: 1.6,
        color: color,
      );
}
