import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

/// Resultado de la racha diaria (§8.4 / §9.3). Siempre positivo.
class DailyResultScreen extends StatelessWidget {
  final int streakDays;
  final bool isBest;
  final bool failed;
  final String message;
  final int hits;
  final int total;

  const DailyResultScreen({
    super.key,
    required this.streakDays,
    required this.isBest,
    required this.failed,
    required this.message,
    required this.hits,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final perfect = !failed && total > 0 && hits == total;
    final String title;
    final String subtitle;
    if (failed) {
      title = 'No te preocupes';
      subtitle = 'Mañana lo harás mejor. La constancia es lo que importa.';
    } else if (perfect) {
      title = '¡Excelente!';
      subtitle = 'Has acertado todas las preguntas de hoy. Vuelve mañana para '
          'mantener tu racha.';
    } else {
      title = '¡Buen trabajo!';
      subtitle = message;
    }

    return PopScope(
      canPop: false,
      child: AppScaffold(
        title: 'Racha diaria',
        showBack: true,
        onBack: () => Navigator.of(context).popUntil((r) => r.isFirst),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: failed ? AppColors.error : AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  failed ? Icons.sentiment_neutral : Icons.check,
                  color: AppColors.onPrimary,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(title, textAlign: TextAlign.center, style: AppTextStyles.h1),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMain.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 28),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      value: '$hits/$total',
                      label: 'ACIERTOS',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(
                    height: 56,
                    child: VerticalDivider(color: AppColors.hairline, width: 1),
                  ),
                  Expanded(
                    child: _StatColumn(
                      value: failed ? '0' : '+1',
                      label: failed ? 'RACHA REINICIADA' : 'DÍA DE RACHA',
                      color: failed ? AppColors.error : AppColors.secondary,
                    ),
                  ),
                ],
              ),
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

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatColumn({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h1.copyWith(color: color, fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textMain.withValues(alpha: 0.5),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
