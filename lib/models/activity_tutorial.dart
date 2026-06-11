import 'package:flutter/material.dart';

/// Una página de tutorial de actividad (§ tutorial por actividad, Anexo 1/6).
///
/// Cada página combina un icono identificativo, un título corto, una frase
/// explicativa y, opcionalmente, un pequeño **ejemplo visual** en pantalla
/// (no solo texto), tal y como recomienda el Anexo 6.
class TutorialPage {
  final IconData icon;
  final String title;
  final String body;

  /// Ejemplo visual opcional que se muestra en lugar del icono grande.
  /// Se construye con un [WidgetBuilder] para poder acceder al contexto
  /// (tema, escalado de texto, etc.). Debe ser ligero y no interactivo
  /// fuera de simples toques (coherente con "solo pulsaciones").
  final WidgetBuilder? example;

  const TutorialPage({
    required this.icon,
    required this.title,
    required this.body,
    this.example,
  });
}

/// Tutorial completo de una actividad: 3 páginas progresivas.
class ActivityTutorial {
  /// Identificador estable para persistir "tutorial visto" (no traducible).
  final String id;

  /// Título mostrado en la cabecera de la pantalla de tutorial.
  final String title;

  /// Las 3 páginas del tutorial (el diseño asume exactamente 3).
  final List<TutorialPage> pages;

  const ActivityTutorial({
    required this.id,
    required this.title,
    required this.pages,
  });
}