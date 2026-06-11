import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

/// Resultado de actividad común y parametrizable (§4.6).
/// Icono de éxito/mejora (nunca solo color) + métricas + mensaje motivacional
/// + "Volver al inicio".
class ActivityResultScreen extends StatelessWidget {
  final String title;
  final List<String> metrics; // líneas de resultado
  final ComparisonOutcome outcome;
  final String message;

  const ActivityResultScreen({
    super.key,
    required this.title,
    required this.metrics,
    required this.outcome,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final improved = outcome == ComparisonOutcome.improved;
    final icon = improved ? Icons.trending_up : Icons.check_circle_outline;
    final iconColor = improved ? AppColors.secondary : AppColors.success;

    return PopScope(
      canPop: false,
      child: AppScaffold(
        title: title,
        showBack: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(child: Icon(icon, size: 84, color: iconColor)),
            const SizedBox(height: 24),
            for (final line in metrics) ...[
              Text(line, style: AppTextStyles.h2),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(message, style: AppTextStyles.body),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Volver al inicio',
              icon: Icons.home_outlined,
              onPressed: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}
