import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_difficulty.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/bar_chart_simple.dart';

/// Estadísticas (Anexo 8). Tres zonas verticales:
///   1) Dato protagonista: racha actual y máxima (dos números grandes).
///   2) Evolución por actividad: un minigráfico por demo (últimas 7 sesiones).
///   3) Datos de contexto: total de partidas y mejor resultado por actividad.
/// Sin diagnósticos ni comparaciones con terceros: solo la evolución personal.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

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
      final nivel = GameDifficultyX.fromKey(best.difficulty).label;
      bestMemory = '${_mmss(best.timeSeconds)} ($nivel)';
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

    return AppScaffold(
      title: 'Estadísticas',
      body: ListView(
        children: [
          // --- Zona superior: dato protagonista (racha) ---
          Row(
            children: [
              Expanded(
                child: _StreakNumber(
                  value: streak.current,
                  label: 'Racha actual',
                  icon: Icons.local_fire_department_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StreakNumber(
                  value: streak.max,
                  label: 'Racha máxima',
                  icon: Icons.emoji_events_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // --- Zona media: evolución por actividad ---
          BarChartSimple(
            title: 'Memory',
            subtitle: 'Tiempo en segundos · menos es mejor',
            data: memoryData,
          ),
          const SizedBox(height: 28),
          BarChartSimple(
            title: 'Reconstruye la frase',
            subtitle: 'Palabras bien colocadas (%) · más es mejor',
            data: sentenceData,
            fixedMax: 100, // métrica en %: eje fijo 0–100 (Anexo 8 §4.1)
          ),
          const SizedBox(height: 28),
          BarChartSimple(
            title: 'Mayor o menor',
            subtitle: 'Tiempo medio en ms · menos es mejor',
            data: numberData,
          ),
          const SizedBox(height: 28),

          // --- Zona inferior: datos de contexto ---
          _ContextCard(
            totalGames: totalGames,
            bestMemory: bestMemory,
            bestSentence: bestSentence,
            bestNumber: bestNumber,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Número grande de racha con icono y etiqueta (información nunca solo color).
class _StreakNumber extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;

  const _StreakNumber({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.cardBorder,
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 32),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 48, // dato protagonista, mínimo 48 sp (Anexo 8 §4.3)
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de datos de contexto: total de partidas y mejor marca por actividad.
class _ContextCard extends StatelessWidget {
  final int totalGames;
  final String bestMemory;
  final String bestSentence;
  final String bestNumber;

  const _ContextCard({
    required this.totalGames,
    required this.bestMemory,
    required this.bestSentence,
    required this.bestNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.cardBorder,
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Partidas completadas', '$totalGames'),
          const SizedBox(height: 12),
          _row('Mejor Memory', bestMemory),
          const SizedBox(height: 12),
          _row('Mejor Reconstruye la frase', bestSentence),
          const SizedBox(height: 12),
          _row('Mejor Mayor o menor', bestNumber),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: AppTextStyles.caption)),
        const SizedBox(width: 12),
        Text(
          value,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}