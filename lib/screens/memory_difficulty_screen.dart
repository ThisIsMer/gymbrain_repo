import 'package:flutter/material.dart';

import '../models/game_difficulty.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import 'memory_game_screen.dart';

/// Selección de dificultad de la Demo 1 (§5.1).
class MemoryDifficultyScreen extends StatelessWidget {
  const MemoryDifficultyScreen({super.key});

  void _start(BuildContext context, GameDifficulty d) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MemoryGameScreen(difficulty: d)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Memory',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Elige la dificultad', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text('Encuentra todas las parejas.', style: AppTextStyles.body),
          const SizedBox(height: 28),
          for (final d in GameDifficulty.values) ...[
            PrimaryButton(
              label: '${d.label}  ·  ${d.pairs} parejas',
              outlined: d != GameDifficulty.normal,
              onPressed: () => _start(context, d),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
