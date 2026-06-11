import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Insignia de feedback (§ feedback nunca solo por color): icono ✓/✕ + color
/// + texto opcional. Reutilizable en todas las demos.
class FeedbackBadge extends StatelessWidget {
  final bool success;
  final String? label;
  final double size;

  const FeedbackBadge({
    super.key,
    required this.success,
    this.label,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.success : AppColors.error;
    final icon = success ? Icons.check_circle_outline : Icons.cancel_outlined;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: size),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(
            label!,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
