import 'package:flutter/material.dart';

extension HexColor on Color {
  static Color fromHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    final padded = clean.length == 6 ? 'FF$clean' : clean;
    return Color(int.parse(padded, radix: 16));
  }

  String toHex({bool includeHash = true}) {
    final r = ((this.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    final g = ((this.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    final b = ((this.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    return '${includeHash ? '#' : ''}$r$g$b'.toUpperCase();
  }
}
