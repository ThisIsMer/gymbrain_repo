import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../services/progress_service.dart';
import '../services/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
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
          // --- Tamaño de texto -------------------------------------------
          Text('Tamaño del texto', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          Column(
            children: [
              for (final option in TextSizeOption.values) ...[
                _TextSizeOptionTile(
                  option: option,
                  selected: settings.textSize == option,
                  onTap: () => settings.setTextSize(option),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // --- Vibración --------------------------------------------------
          Text('Vibración', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Material(
            color: AppColors.surface,
            elevation: AppDimens.cardElevation,
            borderRadius: AppDimens.cardBorder,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vibración al tocar y al acertar o fallar',
                      style: AppTextStyles.body,
                    ),
                  ),
                  Switch(
                    value: settings.vibrationEnabled,
                    onChanged: (v) => settings.setVibration(v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Cómo se juega ---------------------------------------------
          Text('Ayuda', style: AppTextStyles.h2),
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

          // --- Restablecer progreso --------------------------------------
          Text('Datos', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Restablecer progreso',
            icon: Icons.delete_outline,
            outlined: true,
            onPressed: () => _confirmReset(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Se borrarán tu racha, tus respuestas y tus resultados. '
            'No se puede deshacer.',
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progreso restablecido.')),
    );
  }
}

/// Fila seleccionable de tamaño de texto. El estado seleccionado se marca con
/// icono (✓) y borde, nunca solo por color. Muestra una vista previa "Aa".
class _TextSizeOptionTile extends StatelessWidget {
  final TextSizeOption option;
  final bool selected;
  final VoidCallback onTap;

  const _TextSizeOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.surface,
      elevation: AppDimens.cardElevation,
      borderRadius: AppDimens.cardBorder,
      child: InkWell(
        borderRadius: AppDimens.cardBorder,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: AppDimens.cardBorder,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.hairline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  'Aa',
                  style: TextStyle(
                    fontSize: 18 * option.factor,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(option.label, style: AppTextStyles.body),
              ),
              Icon(
                selected
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.primary : AppColors.hairline,
                size: AppDimens.minIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
