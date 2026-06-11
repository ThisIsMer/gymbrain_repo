/// Respuesta a una pregunta diaria (§3.4).
class DailyAnswer {
  String dayIso; // 'yyyy-MM-dd'
  String questionId; // 'wakeup' | 'lunch' | 'afternoon'
  String? text; // null si fue "No me acuerdo"
  bool remembered; // false si pulsó "No me acuerdo"

  DailyAnswer({
    required this.dayIso,
    required this.questionId,
    this.text,
    this.remembered = true,
  });

  Map<String, dynamic> toJson() => {
        'dayIso': dayIso,
        'questionId': questionId,
        'text': text,
        'remembered': remembered,
      };

  factory DailyAnswer.fromJson(Map<String, dynamic> json) {
    return DailyAnswer(
      dayIso: json['dayIso'] as String,
      questionId: json['questionId'] as String,
      text: json['text'] as String?,
      remembered: json['remembered'] as bool? ?? true,
    );
  }
}
