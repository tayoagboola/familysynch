import 'package:flutter/material.dart';

// ── Kid Mode Design Tokens ────────────────────────────────────────────────────
// These override adult tokens for kid_mode screens ONLY.
// Never use these constants outside of lib/features/kid_mode/.

const kidPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF6B35), Color(0xFFFF9A6C), Color(0xFFFFD166)],
  stops: [0.0, 0.5, 1.0],
);

const kidHeaderGradient = LinearGradient(
  begin: Alignment(-0.2, -1),
  end: Alignment(0.3, 1),
  colors: [Color(0xFFFF6B35), Color(0xFFFF9A6C), Color(0xFFFFD166)],
);

const kidBg          = Color(0xFFFFF9F0);
const kidSurface     = Color(0xFFFFFFFF);
const kidTextPrimary = Color(0xFF1A1A2E);
const kidTextSoft    = Color(0xFF6B6B8A);
const kidBorder      = Color(0xFFFFE8DF);
const kidSurface2    = Color(0xFFF5F0EA);

const kidGreen   = Color(0xFF06D6A0);
const kidGreenLight = Color(0xFFE0FAF3);
const kidPrimary = Color(0xFFFF6B35);
const kidPrimaryLight = Color(0xFFFFE8DF);
const kidYellow  = Color(0xFFFFD166);
const kidYellowLight = Color(0xFFFFF8E1);
const kidPurple  = Color(0xFF7C5CBF);
const kidPurpleLight = Color(0xFFEDE6F9);
const kidBlue    = Color(0xFF3A86FF);
const kidBlueLight = Color(0xFFE3EEFF);

// Minimum touch target for children (WCAG)
const kKidMinTouchTarget = 52.0;
