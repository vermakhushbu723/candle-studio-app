import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Small JSON key-value store (session, cart, wishlist, prompts). Initialised once in main().
class LocalStorage {
  LocalStorage._();

  static late SharedPreferences _prefs;

  static const session = 'jy-session';
  static const cart = 'jy-cart';
  static const wishlist = 'jy-wishlist';
  static const pushPrompt = 'jy-push-prompt';
  static const deviceId = 'jy-device';
  static const address = 'jy-address';
  static const followVisited = 'jy-follow-visited';
  static const recentSearches = 'jy-recent-searches';

  static Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  static T? read<T>(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as T;
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(String key, Object? value) => value == null ? _prefs.remove(key) : _prefs.setString(key, jsonEncode(value));
}
