import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

const List<Color> kMemberColors = [
  Color(0xFF2196F3),
  Color(0xFFE91E63),
  Color(0xFF4CAF50),
  Color(0xFFFF9800),
  Color(0xFF9C27B0),
  Color(0xFFFF5722),
];

abstract class AppTheme {
  static const Color _seed = Color(0xFF2E7D6B);

  static ThemeData light() => _base(
        ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light),
      );

  static ThemeData dark() => _base(
        ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
      );

  static ThemeData _base(ColorScheme cs) => ThemeData(
        useMaterial3: true,
        colorScheme: cs,
        textTheme: _text,
        cardTheme: CardThemeData(
          elevation: 0,
          color: cs.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cs.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            textStyle: _text.labelLarge,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      );

  static const TextTheme _text = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  );
}

ThemeData kidModeTheme(ThemeData base) => base.copyWith(
      textTheme: base.textTheme.apply(fontSizeFactor: 1.2),
      iconTheme: const IconThemeData(size: 36),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
