import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text_styles.dart';

/// ThemeData construido a partir de los tokens. Solo modo claro.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textMain,
        error: AppColors.error,
        onError: AppColors.onPrimary,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        displayLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h1,
        titleLarge: AppTextStyles.h2,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        labelLarge: AppTextStyles.button,
        bodySmall: AppTextStyles.caption,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(
          color: AppColors.primary,
          size: AppDimens.minIcon,
        ),
        titleTextStyle: AppTextStyles.h1.copyWith(color: AppColors.primary),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: AppDimens.minIcon,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppDimens.cardElevation,
        shape: RoundedRectangleBorder(borderRadius: AppDimens.cardBorder),
      ),
    );
  }
}
