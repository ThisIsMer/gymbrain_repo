import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/activity_tutorials.dart';
import '../models/activity_tutorial.dart';
import '../models/streak_data.dart';
import '../services/progress_service.dart';
import '../services/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/primary_button.dart';
import 'activity_tutorial_screen.dart';
import 'daily_questions_screen.dart';
import 'memory_difficulty_screen.dart';
import 'number_game_screen.dart';
import 'sentence_game_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// Home (§4.3). Saludo, racha destacada, CTA diario y minijuegos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProgressService _progress;
  late StreakData _streak;

  @override
  void initState() {
    super.initState();
    _progress = context.read<ProgressService>();
    _streak = _progress.loadStreak();
  }

  void _refresh() {
    setState(() {
      _streak = _progress.loadStreak();
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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<SettingsProvider>().userName;
    final answeredToday = _progress.answeredTodayCount();

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting, style: AppTextStyles.caption),
                        Text(
                          userName.isEmpty ? 'Hola' : userName,
                          style: AppTextStyles.h1.copyWith(color: AppColors.textMain),
                        ),
                      ],
                    ),
                  ),
                  _SquareIconButton(
                    icon: Icons.bar_chart_outlined,
                    tooltip: 'Estadísticas',
                    onTap: () => _go(const StatsScreen()),
                  ),
                  const SizedBox(width: 12),
                  _SquareIconButton(
                    icon: Icons.settings_outlined,
                    tooltip: 'Ajustes',
                    onTap: () => _go(const SettingsScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _StreakCard(streak: _streak, answeredToday: answeredToday),
                    if (!_progress.dailyDoneToday()) ...[
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Empezar racha diaria',
                        onPressed: () =>
                            _goActivity(dailyTutorial, const DailyQuestionsScreen()),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const _SectionLabel('MINI-JUEGOS'),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.grid_view_outlined,
                      title: 'Memoria visual',
                      subtitle: 'Encuentra las parejas',
                      onTap: () => _goActivity(
                          memoryTutorial, const MemoryDifficultyScreen()),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.short_text_outlined,
                      title: 'Reconstruye la frase',
                      subtitle: 'Reconstruye la frase que leíste',
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
                    const SizedBox(height: 16),
                    const DisclaimerBanner(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón cuadrado de icono (estadísticas / ajustes) en la cabecera.
class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SquareIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: AppDimens.cardElevation,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: AppDimens.minTouch,
          height: AppDimens.minTouch,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary, size: AppDimens.minIcon),
        ),
      ),
    );
  }
}

/// Tarjeta "Tu racha": días seguidos, mejor racha y progreso de hoy.
class _StreakCard extends StatelessWidget {
  final StreakData streak;
  final int answeredToday;

  const _StreakCard({required this.streak, required this.answeredToday});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_fire_department,
                    color: AppColors.secondary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'TU RACHA',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMain.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${streak.current} ${streak.current == 1 ? 'día' : 'días'} seguidos',
              style: AppTextStyles.h1,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Mejor: ${streak.max}', style: AppTextStyles.caption),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.hairline, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('Preguntas de hoy', style: AppTextStyles.body),
              ),
              Text(
                '$answeredToday / 3',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: answeredToday / 3,
              minHeight: 8,
              backgroundColor: AppColors.hairline,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
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
