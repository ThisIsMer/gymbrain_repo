/// Datos de racha (§3.3).
class StreakData {
  int current; // racha actual (días consecutivos)
  int max; // racha máxima histórica
  String? lastDayIso; // 'yyyy-MM-dd' del último día completado
  int consecutiveDays; // días consecutivos respondiendo (dificultad preguntas)

  StreakData({
    this.current = 0,
    this.max = 0,
    this.lastDayIso,
    this.consecutiveDays = 0,
  });

  Map<String, dynamic> toJson() => {
        'current': current,
        'max': max,
        'lastDayIso': lastDayIso,
        'consecutiveDays': consecutiveDays,
      };

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      current: json['current'] as int? ?? 0,
      max: json['max'] as int? ?? 0,
      lastDayIso: json['lastDayIso'] as String?,
      consecutiveDays: json['consecutiveDays'] as int? ?? 0,
    );
  }

  factory StreakData.empty() => StreakData();
}
