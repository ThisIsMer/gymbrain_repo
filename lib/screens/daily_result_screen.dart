import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

/// Resultado de la racha diaria (§8.4 / §9.3). Siempre positivo.
class DailyResultScreen extends StatelessWidget {
  final int streakDays;
  final bool isBest;
  final String message;

  const DailyResultScreen({
    super.key,
    required this.streakDays,
    required this.isBest,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AppScaffold(
        title: 'Preguntas diarias',
        showBack: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Center(
              child: Icon(Icons.local_fire_department,
                  size: 96, color: AppColors.secondary),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '¡Racha de $streakDays ${streakDays == 1 ? 'día' : 'días'}!',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1.copyWith(color: AppColors.primary),
              ),
            ),
            if (isBest) ...[
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '¡Tu mejor racha hasta ahora!',
                  style: AppTextStyles.h2.copyWith(color: AppColors.secondary),
                ),
              ),
            ],
            const SizedBox(height: 24),
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
