import 'package:flutter/material.dart';

/// Brand palette — same tokens as the website (candle-studio/src/styles/index.css).
class AppColors {
  AppColors._();

  static const cream = Color(0xFFFFF9F5); // page background
  static const shell = Color(0xFFF6EDE4); // soft section background
  static const linen = Color(0xFFEADBC8); // borders
  static const sand = Color(0xFFF7E4D8); // chips, highlights
  static const mist = Color(0xFFE8D5C4);
  static const charcoal = Color(0xFF3A1507); // text, dark sections
  static const ash = Color(0xFF7A5A4C); // secondary text
  static const gold = Color(0xFFC98A4B);
  static const cocoa = Color(0xFF8A3A16);
  static const terracotta = Color(0xFF6C2408); // primary
  static const caramel = Color(0xFFE3A77C); // accent on dark
  static const rose = Color(0xFFC47A5A);

  static const success = Color(0xFF047857);
  static const danger = Color(0xFFDC2626);
  static const whatsapp = Color(0xFF25D366);

  static Color parse(String? hex, [Color fallback = shell]) {
    if (hex == null || !hex.startsWith('#') || (hex.length != 7 && hex.length != 9)) return fallback;
    final v = int.tryParse(hex.substring(1), radix: 16);
    if (v == null) return fallback;
    return Color(hex.length == 7 ? 0xFF000000 | v : v);
  }
}
