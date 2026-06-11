/// Opciones de tamaño de texto (§3.2). Factores 0.9 / 1.0 / 1.2.
enum TextSizeOption { small, normal, large }

extension TextSizeOptionX on TextSizeOption {
  double get factor {
    switch (this) {
      case TextSizeOption.small:
        return 0.9;
      case TextSizeOption.normal:
        return 1.0;
      case TextSizeOption.large:
        return 1.2;
    }
  }

  String get label {
    switch (this) {
      case TextSizeOption.small:
        return 'Pequeño';
      case TextSizeOption.normal:
        return 'Normal';
      case TextSizeOption.large:
        return 'Grande';
    }
  }

  String get key {
    switch (this) {
      case TextSizeOption.small:
        return 'small';
      case TextSizeOption.normal:
        return 'normal';
      case TextSizeOption.large:
        return 'large';
    }
  }

  static TextSizeOption fromKey(String? key) {
    switch (key) {
      case 'small':
        return TextSizeOption.small;
      case 'large':
        return TextSizeOption.large;
      case 'normal':
      default:
        return TextSizeOption.normal;
    }
  }
}

/// Ajustes de la app (§3.2). Solo dos preferencias persistidas.
class AppSettings {
  TextSizeOption textSize;
  bool vibrationEnabled;

  AppSettings({
    this.textSize = TextSizeOption.normal,
    this.vibrationEnabled = true,
  });

  AppSettings copyWith({
    TextSizeOption? textSize,
    bool? vibrationEnabled,
  }) {
    return AppSettings(
      textSize: textSize ?? this.textSize,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'textSize': textSize.key,
        'vibrationEnabled': vibrationEnabled,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      textSize: TextSizeOptionX.fromKey(json['textSize'] as String?),
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  factory AppSettings.defaults() => AppSettings();
}
