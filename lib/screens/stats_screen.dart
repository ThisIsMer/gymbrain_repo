import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/bar_chart_simple.dart';

/// Estadísticas (Anexo 8). Tres zonas verticales:
///   1) Dato protagonista: racha actual y máxima (dos números grandes).
///   2) Evolución por actividad: un minigráfico, con flechas para alternar
///      entre las tres demos (Anexo 8 §4.2; sustituye el swipe por
///      controles táctiles explícitos, WCAG 2.5.7).
///   3) Datos de contexto: total de partidas.
/// Sin diagnósticos ni comparaciones con terceros: solo la evolución personal.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _gameIndex = 0;

  /// Toma como mucho los últimos [maxN] elementos, en orden cronológico.
  static List<T> _lastN<T>(List<T> list, int maxN) {
    if (list.length <= maxN) return list;
    return list.sublist(list.length - maxN);
  }

  /// Etiquetas 1..n para la ventana mostrada (de más antigua a más reciente).
  static List<BarDatum> _toData(List<double> values) {
    return [
      for (int i = 0; i < values.length; i++)
        BarDatum(values[i], '${i + 1}'),
    ];
  }

  static String _mmss(int seconds) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.read<ProgressService>();
    final streak = progress.loadStreak();

    // Histórico completo (para totales y mejores marcas)...
    final allMemory = progress.loadMemorySessions();
    final allSentence = progress.loadSentenceSessions();
    final allNumber = progress.loadNumberSessions();

    // ...y la ventana de las últimas 7 sesiones (para los gráficos).
    final memoryData =
        _toData(_lastN(allMemory, 7).map((s) => s.timeSeconds.toDouble()).toList());
    final sentenceData =
        _toData(_lastN(allSentence, 7).map((s) => s.wordsCorrectPercent).toList());
    final numberData =
        _toData(_lastN(allNumber, 7).map((s) => s.avgReactionMs).toList());

    // Total de partidas completadas (las tres actividades).
    final totalGames =
        allMemory.length + allSentence.length + allNumber.length;

    // Mejor resultado por actividad (— si no hay historial).
    String bestMemory = '—';
    if (allMemory.isNotEmpty) {
      final best =
          allMemory.reduce((a, b) => a.timeSeconds <= b.timeSeconds ? a : b);
      bestMemory = _mmss(best.timeSeconds);
    }

    String bestSentence = '—';
    if (allSentence.isNotEmpty) {
      final best = allSentence
          .map((s) => s.wordsCorrectPercent)
          .reduce((a, b) => a > b ? a : b);
      bestSentence = '${best.round()} %';
    }

    String bestNumber = '—';
    if (allNumber.isNotEmpty) {
      final best =
          allNumber.map((s) => s.avgReactionMs).reduce((a, b) => a < b ? a : b);
      bestNumber = '${best.round()} ms';
    }

    // Las tres demos, para alternar con las flechas Anterior/Siguiente.
    final games = [
      _GameStatCard(
        icon: Icons.grid_view_outlined,
        title: 'Memoria visual',
        subtitle: 'Mejor tiempo',
        value: bestMemory,
        data: memoryData,
      ),
      _GameStatCard(
        icon: Icons.short_text_outlined,
        title: 'Reconstruye la frase',
        subtitle: 'Mejor acierto',
        value: bestSentence,
        data: sentenceData,
        fixedMax: 100, // métrica en %: eje fijo 0–100 (Anexo 8 §4.1)
      ),
      _GameStatCard(
        icon: Icons.compare_arrows_outlined,
        title: 'Mayor o menor',
        subtitle: 'Mejor reacción',
        value: bestNumber,
        data: numberData,
      ),
    ];
    final currentGame = games[_gameIndex];

    return AppScaffold(
      title: 'Estadísticas',
      body: ListView(
        children: [
          // --- Zona superior: dato protagonista (racha) ---
          Row(
            children: [
              Expanded(
                child: _StreakStatCard(
                  icon: Icons.local_fire_department,
                  iconBg: AppColors.secondary.withValues(alpha: 0.14),
                  iconColor: AppColors.secondary,
                  value: streak.current,
                  label: 'Racha actual',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StreakStatCard(
                  icon: Icons.emoji_events_outlined,
                  iconBg: AppColors.primary.withValues(alpha: 0.08),
                  iconColor: AppColors.primary,
                  value: streak.max,
                  label: 'Mejor racha',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Zona media: evolución por actividad (una demo a la vez) ---
          const _SectionLabel('EVOLUCIÓN POR JUEGO'),
          const SizedBox(height: 12),
          currentGame,
          const SizedBox(height: 16),

          // --- Zona inferior: datos de contexto + flechas para cambiar demo ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavArrowButton(
                icon: Icons.arrow_circle_left,
                tooltip: 'Demo anterior',
                onPressed: () => setState(() {
                  _gameIndex = (_gameIndex - 1 + games.length) % games.length;
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Partidas completadas',
                                style: AppTextStyles.body),
                          ),
                          Text(
                            '$totalGames',
                            style: AppTextStyles.h2
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Demo ${_gameIndex + 1} / ${games.length}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _NavArrowButton(
                icon: Icons.arrow_circle_right,
                tooltip: 'Demo siguiente',
                onPressed: () => setState(() {
                  _gameIndex = (_gameIndex + 1) % games.length;
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Flecha grande para alternar entre demos (alternativa táctil al swipe,
/// WCAG 2.5.7) con área mínima 48x48 (WCAG 2.5.8).
class _NavArrowButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _NavArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: AppDimens.minIcon + 8, // más grande = trazo más visible
      color: AppColors.primary,
      tooltip: tooltip,
      constraints: const BoxConstraints(
        minWidth: AppDimens.minTouch,
        minHeight: AppDimens.minTouch,
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

/// Tarjeta de racha: icono + número grande ("X días") + etiqueta.
class _StreakStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final int value;
  final String label;

  const _StreakStatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value ${value == 1 ? 'día' : 'días'}',
      container: true,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(height: 12),
            ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$value', style: AppTextStyles.h1),
                    const SizedBox(width: 6),
                    Text(value == 1 ? 'día' : 'días', style: AppTextStyles.body),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            ExcludeSemantics(
              child: Text(
                label,
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta por actividad: icono + título/subtítulo + mejor marca + gráfico.
class _GameStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final List<BarDatum> data;
  final double? fixedMax;

  const _GameStatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.data,
    this.fixedMax,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BarChartSimple(data: data, fixedMax: fixedMax),
        ],
      ),
    );
  }
}
