import 'package:flutter/material.dart';

/// Dimensiones y estilo base (§2.3).
class AppDimens {
  AppDimens._();

  // Botón principal.
  static const double buttonMinHeight = 56;
  static const double buttonRadius = 12;
  static const double buttonElevation = 2;

  // Tarjeta.
  static const double cardRadius = 16;
  static const double cardElevation = 1;

  // Accesibilidad.
  static const double minTouch = 48; // área táctil mínima dp
  static const double minIcon = 28; // icono mínimo dp

  // Padding de pantalla estándar (20–24 dp horizontal).
  static const double screenPaddingH = 22;
  static const double screenPaddingV = 16;

  // Transición de navegación.
  static const Duration navTransition = Duration(milliseconds: 200);

  // Feedback al pulsar un botón: crece ligeramente.
  static const double pressedScale = 1.05;

  // Bordes redondeados reutilizables.
  static BorderRadius get buttonBorder =>
      BorderRadius.circular(buttonRadius);
  static BorderRadius get cardBorder => BorderRadius.circular(cardRadius);
}
