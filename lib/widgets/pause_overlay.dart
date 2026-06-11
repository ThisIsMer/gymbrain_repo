import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'primary_button.dart';

/// Overlay de Pausa común (§4.5). Capa semitransparente con tarjeta central:
/// "Pausa" + Continuar / Cómo se juega / Ajustes / Volver al menú.
class PauseOverlay extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onHowToPlay;
  final VoidCallback onSettings;
  final VoidCallback onExitToMenu;

  const PauseOverlay({
    super.key,
    required this.onContinue,
    required this.onHowToPlay,
    required this.onSettings,
    required this.onExitToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimens.cardBorder,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pausa',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Continuar',
                icon: Icons.play_arrow_outlined,
                onPressed: onContinue,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Cómo se juega',
                icon: Icons.help_outline,
                outlined: true,
                onPressed: onHowToPlay,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Ajustes',
                icon: Icons.settings_outlined,
                outlined: true,
                onPressed: onSettings,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Volver al menú',
                icon: Icons.home_outlined,
                outlined: true,
                onPressed: onExitToMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
