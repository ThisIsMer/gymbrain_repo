import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Texto legal reutilizable (§2.4). Aparece en Splash, Onboarding y fijo
/// en la parte inferior del Home.
class DisclaimerBanner extends StatelessWidget {
  final Color? color;
  const DisclaimerBanner({super.key, this.color});

  static const String text =
      'Esta aplicación no es una prueba diagnóstica. Si tienes dudas sobre '
      'tu memoria, consulta a tu médico.';

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: AppTextStyles.caption.copyWith(
        color: color ?? AppTextStyles.caption.color,
      ),
    );
  }
}
