import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Display
  static TextStyle get display =>
      GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w900);

  // Headings
  static TextStyle get h1 =>
      GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900);
  static TextStyle get h2 =>
      GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900);
  static TextStyle get h3 =>
      GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900);

  // Body
  static TextStyle get body =>
      GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w600);
  static TextStyle get bodySmall =>
      GoogleFonts.nunitoSans(fontSize: 11, fontWeight: FontWeight.w700);

  // Labels
  static TextStyle get label =>
      GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800);
  static TextStyle get labelSmall =>
      GoogleFonts.nunitoSans(fontSize: 10, fontWeight: FontWeight.w700);
  static TextStyle get caption => GoogleFonts.nunitoSans(
      fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8);
}
