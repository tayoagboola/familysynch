import 'package:flutter/material.dart';

const _gradientPairs = [
  [Color(0xFFFF6B35), Color(0xFFFF9A6C)],
  [Color(0xFF4ECDC4), Color(0xFF6EE7E0)],
  [Color(0xFF7C5CBF), Color(0xFFA07ED0)],
  [Color(0xFFFFD166), Color(0xFFFFE099)],
  [Color(0xFF06D6A0), Color(0xFF3ADFB9)],
  [Color(0xFF3A86FF), Color(0xFF6BA3FF)],
  [Color(0xFFFF4757), Color(0xFFFF7080)],
  [Color(0xFFFF9F43), Color(0xFFFFBE76)],
];

List<Color> memberGradientColors(String memberId) {
  final hash = memberId.codeUnits.fold(0, (acc, c) => acc + c);
  return _gradientPairs[hash % _gradientPairs.length];
}
