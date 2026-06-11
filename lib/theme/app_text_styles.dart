import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografía Nunito.
///
/// Los tamaños base aquí definidos NO se multiplican manualmente por el
/// factor de tamaño de texto del usuario: ese escalado se aplica de forma
/// global mediante el `TextScaler` configurado en [app.dart] (ver §3.2).
/// Reglas: alineación a la izquierda, interlineado >= 1.5, color textMain
/// salvo sobre fondos primary (blanco).
class AppTextStyles {
  AppTextStyles._();

  static const double _height = 1.5;

  static TextStyle get h1 => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: _height,
        color: AppColors.textMain,
      );

  static TextStyle get h2 => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: _height,
        color: AppColors.textMain,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: _height,
        color: AppColors.textMain,
      );

  static TextStyle get button => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.onPrimary,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: _height,
        color: AppColors.textMain,
      );
}
