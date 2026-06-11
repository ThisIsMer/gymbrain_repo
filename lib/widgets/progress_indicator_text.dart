import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Indicador "X de N" (texto) + barra opcional. Usado en las demos.
class ProgressIndicatorText extends StatelessWidget {
  final int current; // 1-based
  final int total;
  final String prefix; // p.ej. "Frase", "Pregunta"

  const ProgressIndicatorText({
    super.key,
    required this.current,
    required this.total,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    final label = prefix.isEmpty ? '$current de $total' : '$prefix $current de $total';
    final fraction = total == 0 ? 0.0 : (current.clamp(0, total)) / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: AppColors.hairline,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
