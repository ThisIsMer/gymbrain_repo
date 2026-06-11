import 'package:flutter/material.dart';

/// Paleta de color exacta (Sistema de diseño, Opción A).
/// El color NUNCA es el único transmisor de información: todo estado
/// (acierto/fallo) se acompaña siempre de icono y/o texto.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1B3A6B); // Azul marino
  static const Color secondary = Color(0xFFE8742A); // Naranja suave
  static const Color background = Color(0xFFF7F8FC); // Blanco hueso
  static const Color surface = Color(0xFFFFFFFF); // Blanco
  static const Color textMain = Color(0xFF1A1A2E); // Gris oscuro
  static const Color success = Color(0xFF2E7D32); // Verde
  static const Color error = Color(0xFFC62828); // Rojo
  static const Color onPrimary = Color(0xFFFFFFFF); // Texto sobre primary

  /// Borde fino reutilizado en tarjetas de palabras, etc.
  static const Color hairline = Color(0xFFE2E6F0);
}
