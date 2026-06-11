/// Sesión de la Demo 1 (Memory) para historial y estadísticas (§3.5).
class MemorySession {
  String dateIso;
  String difficulty; // 'facil' | 'normal' | 'dificil'
  int timeSeconds; // tiempo total
  int failedRevisits; // revisitas fallidas (0 = partida perfecta)

  MemorySession({
    required this.dateIso,
    required this.difficulty,
    required this.timeSeconds,
    required this.failedRevisits,
  });

  Map<String, dynamic> toJson() => {
        'dateIso': dateIso,
        'difficulty': difficulty,
        'timeSeconds': timeSeconds,
        'failedRevisits': failedRevisits,
      };

  factory MemorySession.fromJson(Map<String, dynamic> json) {
    return MemorySession(
      dateIso: json['dateIso'] as String,
      difficulty: json['difficulty'] as String,
      timeSeconds: json['timeSeconds'] as int? ?? 0,
      failedRevisits: json['failedRevisits'] as int? ?? 0,
    );
  }
}
