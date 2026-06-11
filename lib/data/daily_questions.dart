/// Las 3 preguntas diarias y sus formulaciones según distancia temporal (§8).
class DailyQuestionDef {
  final String id; // 'wakeup' | 'lunch' | 'afternoon'
  final String today; // formulación "hoy"
  final String yesterday; // formulación "ayer"
  final String dayBefore; // formulación "anteayer"

  const DailyQuestionDef({
    required this.id,
    required this.today,
    required this.yesterday,
    required this.dayBefore,
  });
}

const List<DailyQuestionDef> dailyQuestionDefs = [
  DailyQuestionDef(
    id: 'wakeup',
    today: '¿A qué hora te has levantado hoy?',
    yesterday: '¿A qué hora te levantaste ayer?',
    dayBefore: '¿A qué hora te levantaste anteayer?',
  ),
  DailyQuestionDef(
    id: 'lunch',
    today: '¿Qué has comido hoy?',
    yesterday: '¿Qué comiste ayer?',
    dayBefore: '¿Qué comiste anteayer?',
  ),
  DailyQuestionDef(
    id: 'afternoon',
    today: '¿A qué vas a dedicar la tarde de hoy?',
    yesterday: '¿A qué dedicaste la tarde de ayer?',
    dayBefore: '¿A qué dedicaste la tarde de anteayer?',
  ),
];

/// Una pregunta concreta de la rutina del día, ya con su formulación y el
/// desfase de días que referencia (0 = hoy, 1 = ayer, 2 = anteayer).
class ResolvedQuestion {
  final String questionId;
  final String text;
  final int dayOffset; // 0 hoy, 1 ayer, 2 anteayer

  const ResolvedQuestion({
    required this.questionId,
    required this.text,
    required this.dayOffset,
  });
}
