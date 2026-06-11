import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Tarjeta estándar (§2.3): fondo surface, borderRadius 16, elevation 1.
/// Toda la tarjeta es pulsable si se pasa [onTap] (área >= 48dp).
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? background;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background ?? AppColors.surface,
      elevation: AppDimens.cardElevation,
      borderRadius: AppDimens.cardBorder,
      child: InkWell(
        borderRadius: AppDimens.cardBorder,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
