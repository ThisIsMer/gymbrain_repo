import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper de `shared_preferences` (§3). Todas las claves bajo prefijo `gb_`.
/// Objetos complejos se serializan como JSON. Nunca usa web/localStorage.
/// Todo acceso va protegido con try/catch.
class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  // Claves (§3.1)
  static const String kOnboardingDone = 'gb_onboarding_done';
  static const String kSettings = 'gb_settings';
  static const String kStreak = 'gb_streak';
  static const String kDailyAnswers = 'gb_daily_answers';
  static const String kSessionsMemory = 'gb_sessions_memory';
  static const String kSessionsSentence = 'gb_sessions_sentence';
  static const String kSessionsNumber = 'gb_sessions_number';
  static const String kSentenceSeenIds = 'gb_sentence_seen_ids';
  static const String kTutorialsSeen = 'gb_tutorials_seen';


  static const List<String> allKeys = [
    kOnboardingDone,
    kSettings,
    kStreak,
    kDailyAnswers,
    kSessionsMemory,
    kSessionsSentence,
    kSessionsNumber,
    kSentenceSeenIds,
    kTutorialsSeen,
  ];

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  // --- Primitivas -----------------------------------------------------------

  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _prefs.getBool(key) ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (_) {
      // Persistencia best-effort; nunca crashea el loop jugable.
    }
  }

  /// Lee un objeto JSON (Map) almacenado como string.
  Map<String, dynamic>? getJsonMap(String key) {
    try {
      final raw = _prefs.getString(key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> setJsonMap(String key, Map<String, dynamic> value) async {
    try {
      await _prefs.setString(key, jsonEncode(value));
    } catch (_) {}
  }

  /// Lee una lista JSON (List<Map>) almacenada como string.
  List<Map<String, dynamic>> getJsonList(String key) {
    try {
      final raw = _prefs.getString(key);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> setJsonList(
      String key, List<Map<String, dynamic>> value) async {
    try {
      await _prefs.setString(key, jsonEncode(value));
    } catch (_) {}
  }

  /// Lista de strings simples (p.ej. ids de frases vistas).
  List<String> getStringList(String key) {
    try {
      return _prefs.getStringList(key) ?? <String>[];
    } catch (_) {
      return <String>[];
    }
  }

  Future<void> setStringList(String key, List<String> value) async {
    try {
      await _prefs.setStringList(key, value);
    } catch (_) {}
  }

  /// Borra todas las claves `gb_*` (Restablecer progreso, §4.8).
  Future<void> clearAll() async {
    try {
      for (final key in allKeys) {
        await _prefs.remove(key);
      }
    } catch (_) {}
  }
}
