/// Sesión de la Demo 2 (Reconstruye la frase) (§3.5).
class SentenceSession {
  String dateIso;
  int correctSentences; // 0..10
  double wordsCorrectPercent; // 0..100
  int maxSentenceLength; // longitud máxima alcanzada

  SentenceSession({
    required this.dateIso,
    required this.correctSentences,
    required this.wordsCorrectPercent,
    required this.maxSentenceLength,
  });

  Map<String, dynamic> toJson() => {
        'dateIso': dateIso,
        'correctSentences': correctSentences,
        'wordsCorrectPercent': wordsCorrectPercent,
        'maxSentenceLength': maxSentenceLength,
      };

  factory SentenceSession.fromJson(Map<String, dynamic> json) {
    return SentenceSession(
      dateIso: json['dateIso'] as String,
      correctSentences: json['correctSentences'] as int? ?? 0,
      wordsCorrectPercent:
          (json['wordsCorrectPercent'] as num?)?.toDouble() ?? 0,
      maxSentenceLength: json['maxSentenceLength'] as int? ?? 0,
    );
  }
}
