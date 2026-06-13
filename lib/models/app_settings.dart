/// Opciones de tamaño de texto (§3.2).
/// Factores calculados para que el texto más pequeño (caption, base 18px)
/// quede en 14 / 18 / 20 px: 14/18, 1.0, 20/18.
enum TextSizeOption { small, normal, large }

extension TextSizeOptionX on TextSizeOption {
  double get factor {
    switch (this) {
      case TextSizeOption.small:
        return 14 / 18;
      case TextSizeOption.normal:
        return 1.0;
      case TextSizeOption.large:
        return 20 / 18;
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
  String userName;

  AppSettings({
    this.textSize = TextSizeOption.normal,
    this.vibrationEnabled = true,
    this.userName = '',
  });

  AppSettings copyWith({
    TextSizeOption? textSize,
    bool? vibrationEnabled,
    String? userName,
  }) {
    return AppSettings(
      textSize: textSize ?? this.textSize,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      userName: userName ?? this.userName,
    );
  }

  Map<String, dynamic> toJson() => {
        'textSize': textSize.key,
        'vibrationEnabled': vibrationEnabled,
        'userName': userName,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      textSize: TextSizeOptionX.fromKey(json['textSize'] as String?),
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      userName: json['userName'] as String? ?? '',
    );
  }

  factory AppSettings.defaults() => AppSettings();
}
