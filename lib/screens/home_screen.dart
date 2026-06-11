import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/activity_tutorials.dart';
import '../models/activity_tutorial.dart';
import '../models/streak_data.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/disclaimer_banner.dart';
import 'activity_tutorial_screen.dart';
import 'daily_questions_screen.dart';
import 'memory_difficulty_screen.dart';
import 'number_game_screen.dart';
import 'sentence_game_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// Home (§4.3). Saludo, racha destacada, 6 zonas de acción, disclaimer fijo.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreakData _streak;

  @override
  void initState() {
    super.initState();
    _streak = context.read<ProgressService>().loadStreak();
  }

  void _refresh() {
    setState(() {
      _streak = context.read<ProgressService>().loadStreak();
    });
  }

  Future<void> _go(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (mounted) _refresh();
  }

  /// Lanza una actividad mostrando antes su tutorial si aún no se ha visto.
  /// El tutorial devuelve `true` al pulsar "Empezar"/"Saltar"; si el usuario
  /// lo cierra de otro modo, no se entra en la actividad.
  Future<void> _goActivity(ActivityTutorial tut, Widget screen) async {
    final progress = context.read<ProgressService>();
    if (!progress.tutorialSeen(tut.id)) {
      final start = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ActivityTutorialScreen(tutorial: tut),
        ),
      );
      if (start != true) {
        if (mounted) _refresh();
        return;
      }
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (mounted) _refresh();
  }

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
              Text('Hola', style: AppTextStyles.h1.copyWith(color: AppColors.primary)),
              const SizedBox(height: 8),
              _StreakChip(days: _streak.current),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    // 1. Preguntas diarias (destacada, ancho completo).
                    _ActionCard(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Preguntas diarias',
                      subtitle: 'Tu racha de cada día',
                      accent: AppColors.secondary,
                      highlighted: true,
                      onTap: () =>
                          _goActivity(dailyTutorial, const DailyQuestionsScreen()),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.grid_view_outlined,
                      title: 'Memory',
                      subtitle: 'Encuentra las parejas',
                      onTap: () => _goActivity(
                          memoryTutorial, const MemoryDifficultyScreen()),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.short_text_outlined,
                      title: 'Reconstruye la frase',
                      subtitle: 'Memoriza y ordena las palabras',
                      onTap: () => _goActivity(
                          sentenceTutorial, const SentenceGameScreen()),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.compare_arrows_outlined,
                      title: 'Mayor o menor',
                      subtitle: 'Elige el número correcto',
                      onTap: () =>
                          _goActivity(numberTutorial, const NumberGameScreen()),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.bar_chart_outlined,
                      title: 'Estadísticas',
                      subtitle: 'Tu progreso',
                      onTap: () => _go(const StatsScreen()),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.settings_outlined,
                      title: 'Ajustes',
                      subtitle: 'Tamaño de texto y más',
                      onTap: () => _go(const SettingsScreen()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const DisclaimerBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  final int days;
  const _StreakChip({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department,
              color: AppColors.secondary, size: AppDimens.minIcon),
          const SizedBox(width: 8),
          Text(
            'Racha: $days ${days == 1 ? 'día' : 'días'}',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? accent;
  final bool highlighted;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.accent,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = accent ?? AppColors.secondary;
    return AppCard(
      onTap: onTap,
      background: highlighted
          ? AppColors.secondary.withValues(alpha: 0.10)
          : AppColors.surface,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h2),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.primary),
        ],
      ),
    );
  }
}