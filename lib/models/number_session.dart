/// Sesión de la Demo 3 (Mayor o menor) (§3.5).
class NumberSession {
  String dateIso;
  double avgReactionMs; // tiempo medio de respuesta
  double stdReactionMs; // desviación típica intrasesión
  int hits; // aciertos totales (de 10)
  int hits1, hits2, hits3; // aciertos por nº de cifras
  double avg2DigitsMs; // media en ensayos de 2 cifras (arranque siguiente)
  double hit2DigitsPct; // % aciertos en 2 cifras

  NumberSession({
    required this.dateIso,
    required this.avgReactionMs,
    required this.stdReactionMs,
    required this.hits,
    required this.hits1,
    required this.hits2,
    required this.hits3,
    required this.avg2DigitsMs,
    required this.hit2DigitsPct,
  });

  Map<String, dynamic> toJson() => {
        'dateIso': dateIso,
        'avgReactionMs': avgReactionMs,
        'stdReactionMs': stdReactionMs,
        'hits': hits,
        'hits1': hits1,
        'hits2': hits2,
        'hits3': hits3,
        'avg2DigitsMs': avg2DigitsMs,
        'hit2DigitsPct': hit2DigitsPct,
      };

  factory NumberSession.fromJson(Map<String, dynamic> json) {
    return NumberSession(
      dateIso: json['dateIso'] as String,
      avgReactionMs: (json['avgReactionMs'] as num?)?.toDouble() ?? 0,
      stdReactionMs: (json['stdReactionMs'] as num?)?.toDouble() ?? 0,
      hits: json['hits'] as int? ?? 0,
      hits1: json['hits1'] as int? ?? 0,
      hits2: json['hits2'] as int? ?? 0,
      hits3: json['hits3'] as int? ?? 0,
      avg2DigitsMs: (json['avg2DigitsMs'] as num?)?.toDouble() ?? 0,
      hit2DigitsPct: (json['hit2DigitsPct'] as num?)?.toDouble() ?? 0,
    );
  }
}
