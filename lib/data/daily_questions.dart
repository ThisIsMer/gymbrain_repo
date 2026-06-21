/// Las 3 preguntas diarias y sus formulaciones según distancia temporal (§8).
class DailyQuestionDef {
  final String id; // 'wakeup' | 'lunch' | 'afternoon'
  final String today; // formulación "hoy"
  final String yesterday; // formulación "ayer"
  final String dayBefore; // formulación "anteayer"
  final String pastTemplate; // formulación genérica "hace {n} días"

  const DailyQuestionDef({
    required this.id,
    required this.today,
    required this.yesterday,
    required this.dayBefore,
    required this.pastTemplate,
  });

  /// Formulación de la pregunta para un desfase de días dado (0 = hoy,
  /// 1 = ayer, 2 = anteayer, 3+ = "hace N días").
  String textFor(int offset) {
    switch (offset) {
      case 0:
        return today;
      case 1:
        return yesterday;
      case 2:
        return dayBefore;
      default:
        return pastTemplate.replaceAll('{n}', '$offset');
    }
  }
}

const List<DailyQuestionDef> dailyQuestionDefs = [
  DailyQuestionDef(
    id: 'wakeup',
    today: '¿A qué hora te has levantado hoy?',
    yesterday: '¿A qué hora te levantaste ayer?',
    dayBefore: '¿A qué hora te levantaste anteayer?',
    pastTemplate: '¿A qué hora te levantaste hace {n} días?',
  ),
  DailyQuestionDef(
    id: 'lunch',
    today: '¿Qué has comido hoy?',
    yesterday: '¿Qué comiste ayer?',
    dayBefore: '¿Qué comiste anteayer?',
    pastTemplate: '¿Qué comiste hace {n} días?',
  ),
  DailyQuestionDef(
    id: 'afternoon',
    today: '¿A qué vas a dedicar la tarde de hoy?',
    yesterday: '¿A qué dedicaste la tarde de ayer?',
    dayBefore: '¿A qué dedicaste la tarde de anteayer?',
    pastTemplate: '¿A qué dedicaste la tarde de hace {n} días?',
  ),
];

/// Una pregunta concreta de la rutina del día, ya con su formulación y el
/// desfase de días que referencia (0 = hoy, 1 = ayer, 2 = anteayer, ...).
class ResolvedQuestion {
  final String questionId;
  final String text;
  final int dayOffset;

  const ResolvedQuestion({
    required this.questionId,
    required this.text,
    required this.dayOffset,
  });
}
