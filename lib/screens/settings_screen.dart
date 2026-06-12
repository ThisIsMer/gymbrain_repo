import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../services/progress_service.dart';
import '../services/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import 'onboarding_screen.dart';

/// Ajustes (§4.8): tamaño de texto, vibración, "Cómo se juega" y
/// "Restablecer progreso". Sin opciones superfluas (menos es más).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return AppScaffold(
      title: 'Ajustes',
      body: ListView(
        children: [
          // --- Accesibilidad ----------------------------------------------
          const _SectionLabel('ACCESIBILIDAD'),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tamaño de texto', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text('Afecta a todas las pantallas',
                    style: AppTextStyles.caption),
                const SizedBox(height: 12),
                _TextSizeSegmented(
                  selected: settings.textSize,
                  onChanged: (option) => settings.setTextSize(option),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Sonido -------------------------------------------------------
          const _SectionLabel('SONIDO'),
          const SizedBox(height: 8),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Vibración al pulsar',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Switch(
                  value: settings.vibrationEnabled,
                  activeThumbColor: AppColors.success,
                  onChanged: (v) => settings.setVibration(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Ayuda ----------------------------------------------------------
          const _SectionLabel('AYUDA'),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Cómo se juega',
            icon: Icons.help_outline,
            outlined: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OnboardingScreen(reviewMode: true),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Datos ----------------------------------------------------------
          const _SectionLabel('DATOS'),
          const SizedBox(height: 8),
          AppCard(
            onTap: () => _confirmReset(context),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restablecer progreso',
                        style: AppTextStyles.h2.copyWith(color: AppColors.error),
                      ),
                      const SizedBox(height: 2),
                      Text('Borra racha, historial y nivel',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.error),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'GymBrain · Versión 1.0',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final progress = context.read<ProgressService>();
    final settings = context.read<SettingsProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppDimens.cardBorder),
          title: Text('¿Restablecer el progreso?', style: AppTextStyles.h2),
          content: Text(
            'Se borrarán tu racha, tus respuestas y tus resultados. '
            'Esta acción no se puede deshacer.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancelar',
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Restablecer',
                style: AppTextStyles.button.copyWith(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await progress.resetAll();
    await settings.resetToDefaults();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }
}

/// Etiqueta de sección en mayúsculas (gris, espaciada).
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textMain.withValues(alpha: 0.5),
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Control segmentado Pequeño / Normal / Grande para el tamaño de texto.
class _TextSizeSegmented extends StatelessWidget {
  final TextSizeOption selected;
  final ValueChanged<TextSizeOption> onChanged;

  const _TextSizeSegmented({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final option in TextSizeOption.values)
            Expanded(
              child: _TextSizeSegment(
                option: option,
                selected: option == selected,
                onTap: () => onChanged(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _TextSizeSegment extends StatelessWidget {
  final TextSizeOption option;
  final bool selected;
  final VoidCallback onTap;

  const _TextSizeSegment({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            option.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.onPrimary : AppColors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}
