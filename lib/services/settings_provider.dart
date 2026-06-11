import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  void hapticSuccess() {
    if (_settings.vibrationEnabled) HapticFeedback.selectionClick();
  }

  void hapticError() {
    if (_settings.vibrationEnabled) HapticFeedback.heavyImpact();
  }
}
