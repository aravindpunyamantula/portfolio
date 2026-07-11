import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0B0F19),
    // Poppins is bundled locally (assets/fonts) — no runtime font fetch.
    fontFamily: 'Poppins',
    textTheme: Typography.whiteMountainView.apply(
      fontFamily: 'Poppins',
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF22C55E),
    ),
  );
}
