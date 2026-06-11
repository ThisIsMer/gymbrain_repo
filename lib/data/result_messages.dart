/// Mensajes de resultado (§9). Nunca penalizan ni regañan.
class ResultMessages {
  ResultMessages._();

  /// Mejora respecto al historial: celebrar comparando con uno mismo.
  static const List<String> improved = [
    '¡Has mejorado tu mejor marca!',
    'Hoy lo has hecho mejor que la última vez.',
    '¡Vas a más! Sigue así.',
    'Tu esfuerzo se nota. ¡Enhorabuena!',
  ];

  /// Igual o peor: mensaje normalizador / de ánimo (sin cifras negativas).
  static const List<String> neutral = [
    'Buen trabajo, sigue así.',
    'Cada día cuenta.',
    'Lo importante es la constancia.',
    'Has completado la actividad. ¡Bien hecho!',
  ];

  /// Primera vez (sin historial).
  static const String firstTime =
      '¡Primera marca registrada! A partir de aquí solo se trata de superarte a ti mismo.';

  /// Resultado de racha.
  static const String streakBase = '¡Racha de {x} días!';
  static const String streakBest = '¡Tu mejor racha hasta ahora!';
}
