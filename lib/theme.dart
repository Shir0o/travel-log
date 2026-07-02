import 'package:flutter/material.dart';

class BrutalTheme {
  // Theme Colors
  static const Color primary = Color(0xFFFF007F); // Neon Pink
  static const Color yellow = Color(0xFFFFFF00); // Brand Yellow
  static const Color cyan = Color(0xFF00E5FF); // Brand Cyan
  static const Color backgroundLight = Color(0xFFF9F8F6); // Messy light background
  static const Color backgroundDark = Color(0xFF221019); // Deep dark background
  static const Color inkBlack = Color(0xFF111111); // Thick border and text black
  static const Color graphite = Color(0xFF888888); // Muted gray

  // Standard Brutalist Border
  static Border brutalBorder({double width = 3.0, Color color = inkBlack}) {
    return Border.all(
      color: color,
      width: width,
    );
  }

  // Standard Brutalist Shadow
  static List<BoxShadow> brutalShadow({
    Offset offset = const Offset(4, 4),
    Color color = inkBlack,
  }) {
    return [
      BoxShadow(
        color: color,
        offset: offset,
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }

  // Helper decoration
  static BoxDecoration brutalDecoration({
    Color color = Colors.white,
    BorderRadiusGeometry? borderRadius,
    double borderWidth = 3.0,
    Color borderColor = inkBlack,
    Offset shadowOffset = const Offset(4, 4),
    Color shadowColor = inkBlack,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      color: color,
      border: brutalBorder(width: borderWidth, color: borderColor),
      borderRadius: borderRadius ?? BorderRadius.zero,
      boxShadow: showShadow ? brutalShadow(offset: shadowOffset, color: shadowColor) : null,
    );
  }
}
