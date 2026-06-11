import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Andamiaje común para pantallas no-Home (§4): título h1 (color primary)
/// arriba y botón "volver" a la izquierda. Fondo background, SafeArea.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? bottom; // contenido fijo inferior (p.ej. disclaimer)

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH,
            vertical: AppDimens.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (showBack)
                    IconButton(
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.primary,
                      iconSize: AppDimens.minIcon,
                      tooltip: 'Volver',
                      constraints: const BoxConstraints(
                        minWidth: AppDimens.minTouch,
                        minHeight: AppDimens.minTouch,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
              const SizedBox(height: 12),
              Expanded(child: body),
              if (bottom != null) ...[
                const SizedBox(height: 12),
                bottom!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
