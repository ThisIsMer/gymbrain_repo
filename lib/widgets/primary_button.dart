import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Botón principal estándar (§2.3): relleno primary, texto blanco,
/// borderRadius 12, altura mínima 56, elevation 2.
/// Feedback al pulsar: crece ~1.05 y se mantiene hasta el siguiente evento.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  /// Variante secundaria: contorno primary sobre fondo blanco.
  final bool outlined;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.outlined = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _grown = false;

  void _handleTap() {
    if (widget.onPressed == null) return;
    setState(() => _grown = true);
    context.read<SettingsProvider>().hapticLight();
    widget.onPressed!.call();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.outlined ? AppColors.surface : AppColors.primary;
    final fg = widget.outlined ? AppColors.primary : AppColors.onPrimary;
    final disabled = widget.onPressed == null;

    final child = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: fg, size: AppDimens.minIcon),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.button.copyWith(color: fg),
          ),
        ),
      ],
    );

    return AnimatedScale(
      scale: _grown ? AppDimens.pressedScale : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Material(
          color: bg,
          elevation: widget.outlined ? 0 : AppDimens.buttonElevation,
          borderRadius: AppDimens.buttonBorder,
          child: InkWell(
            borderRadius: AppDimens.buttonBorder,
            onTap: disabled ? null : _handleTap,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppDimens.buttonMinHeight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: AppDimens.buttonBorder,
                border: widget.outlined
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
