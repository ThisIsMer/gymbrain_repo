import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../models/app_settings.dart';
import 'storage_service.dart';

/// Estado de ajustes (tamaño de texto, vibración). ChangeNotifier (provider).
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storage) {
    _load();
  }

  final StorageService _storage;
  AppSettings _settings = AppSettings.defaults();

  AppSettings get settings => _settings;
  TextSizeOption get textSize => _settings.textSize;
  bool get vibrationEnabled => _settings.vibrationEnabled;
  String get userName => _settings.userName;

  /// Factor aplicado al `TextScaler` global (§3.2).
  double get textScaleFactor => _settings.textSize.factor;

  void _load() {
    final json = _storage.getJsonMap(StorageService.kSettings);
    if (json != null) {
      _settings = AppSettings.fromJson(json);
    }
  }

  Future<void> _persist() async {
    await _storage.setJsonMap(StorageService.kSettings, _settings.toJson());
  }

  Future<void> setTextSize(TextSizeOption option) async {
    if (_settings.textSize == option) return;
    _settings = _settings.copyWith(textSize: option);
    notifyListeners();
    await _persist();
  }

  Future<void> setVibration(bool enabled) async {
    if (_settings.vibrationEnabled == enabled) return;
    _settings = _settings.copyWith(vibrationEnabled: enabled);
    notifyListeners();
    await _persist();
  }

  Future<void> setUserName(String name) async {
    if (_settings.userName == name) return;
    _settings = _settings.copyWith(userName: name);
    notifyListeners();
    await _persist();
  }

  /// Restablece ajustes a valores por defecto (parte de "Restablecer progreso").
  Future<void> resetToDefaults() async {
    _settings = AppSettings.defaults();
    notifyListeners();
    await _persist();
  }

  // --- Hápticos -------------------------------------------------------------

  void hapticLight() {
    if (_settings.vibrationEnabled) HapticFeedback.lightImpact();
  }

  /// Vibración genérica para cualquier toque sobre un elemento interactuable.
  /// Usa el motor de vibración directamente (paquete `vibration`), que no
  /// depende del ajuste de "vibración táctil" del sistema como sí ocurre
  /// con los HapticFeedback.* (performHapticFeedback).
  void hapticTap() {
    if (!_settings.vibrationEnabled) return;
    debugPrint('[haptic] hapticTap() -> Vibration.vibrate');
    Vibration.vibrate(duration: 150, amplitude: 255).then((_) {
      debugPrint('[haptic] vibrate() completed');
    }).catchError((Object e) {
      debugPrint('[haptic] vibrate() error: $e');
    });
    Vibration.hasVibrator().then((v) => debugPrint('[haptic] hasVibrator=$v'));
    Vibration.hasAmplitudeControl()
        .then((v) => debugPrint('[haptic] hasAmplitudeControl=$v'));
  }

  void hapticSuccess() {
    if (_settings.vibrationEnabled) HapticFeedback.selectionClick();
  }

  void hapticError() {
    if (_settings.vibrationEnabled) HapticFeedback.heavyImpact();
  }
}
