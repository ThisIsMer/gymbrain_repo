import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Barra superior común de las pantallas de actividad: volver + título + pausa.
class ActivityTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onPause;

  const ActivityTopBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
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
            textAlign: TextAlign.center,
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
        ),
        IconButton(
          onPressed: onPause,
          icon: const Icon(Icons.pause_circle_outline),
          color: AppColors.primary,
          iconSize: AppDimens.minIcon,
          tooltip: 'Pausa',
          constraints: const BoxConstraints(
            minWidth: AppDimens.minTouch,
            minHeight: AppDimens.minTouch,
          ),
        ),
      ],
    );
  }
}
