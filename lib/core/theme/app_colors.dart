import 'package:flutter/material.dart';

/// Neutral dark palette ported 1:1 from the approved HTML prototype.
/// Grayscale zinc only — no hue anywhere in the UI chrome.
abstract final class AppColors {
  static const Color page = Color(0xFF09090B);
  static const Color phone = Color(0xFF101013);
  static const Color surface = Color(0xFF1A1A1E);
  static const Color surface2 = Color(0xFF232329);
  static const Color border = Color(0xFF26262C);
  static const Color text = Color(0xFFFAFAF9);
  static const Color muted = Color(0xFFA1A1AA);
  static const Color faint = Color(0xFF71717A);
  static const Color accent = Color(0xFFFAFAF9);
  static const Color accentInk = Color(0xFF09090B);

  static const Gradient cardFallback = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface2, phone],
  );

  static const Gradient captionScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.65)],
  );
}
