import 'package:flutter/material.dart';

class HomeSpacing {
  static const double screenPadding = 24.0;
  static const double sectionGap = 20.0;
  static const double cardPadding = 18.0;
  static const double itemGap = 10.0;
}

class HomeRadius {
  static const double card = 20.0;
  static const double item = 12.0;
  static const double tag = 8.0;
  static const double button = 14.0;
  static const double avatar = 14.0;
}

class HomeShadow {
  static const card = BoxShadow(
    color: Color(0x141A1A2E),
    blurRadius: 20,
    offset: Offset(0, 4),
  );
  static const large = BoxShadow(
    color: Color(0x1F1A1A2E),
    blurRadius: 40,
    offset: Offset(0, 8),
  );
}
