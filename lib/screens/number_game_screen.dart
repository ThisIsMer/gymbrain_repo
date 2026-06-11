import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/activity_tutorials.dart';
import '../models/number_session.dart';
import '../services/progress_service.dart';
import '../services/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/activity_top_bar.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_indicator_text.dart';
import 'activity_result_screen.dart';
import 'activity_tutorial_screen.dart';
import 'settings_screen.dart';

const int _totalTrials = 10;

/// Umbral provisional del prototipo para el arranque adaptativo (§7.1).
const double _kAdaptiveMaxMs = 2500;
const double _kAdaptiveMinHitPct = 80;

enum _Phase { prep, trial, feedback }

/// Definición de un ensayo de "Mayor o menor".
class _Trial {
  final int left;
  final int right;
  final bool conditionMayor; // true = mayor, false = menor
  final int digits; // 1, 2 o 3 cifras

  const _Trial({
    required this.left,
    required this.right,
    required this.conditionMayor,
    required this.digits,
  });

  /// Valor que el usuario debería tocar.
  int get targetValue => conditionMayor ? max(left, right) : min(left, right);
  bool isLeftCorrect() => left == targetValue;
}

/// Demo 3 — Mayor o menor (velocidad de procesamiento) (§7).
class NumberGameScreen extends StatefulWidget {
  const NumberGameScreen({super.key});

  @override
  State<NumberGameScreen> createState() => _NumberGameScreenState();
}

class _NumberGameScreenState extends State<NumberGameScreen> {
  final Random _rng = Random();
  late final ProgressService _progress;

  late final bool _adaptiveStart; // omite ensayos de 1 cifra
  late _Trial _current;

  final List<int> _latencies = []; // ms por ensayo
  final List<int> _trialDigits = []; // nº de cifras por ensayo
  final List<bool> _trialHits = []; // acierto/fallo por ensayo

  int _trialIndex = 0; // 0-based (10 ensayos)
  _Phase _phase = _Phase.prep;
  final Stopwatch _stopwatch = Stopwatch();

  // Estado del feedback inmediato (~400 ms).
  bool? _lastTapWasLeft;
  bool _lastTapCorrect = false;

  bool _paused = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _progress = context.read<ProgressService>();
    _adaptiveStart = _computeAdaptiveStart();
    _prepareTrial();
  }

  // --- Arranque adaptativo entre sesiones (§7.1) ----------------------------

  bool _computeAdaptiveStart() {
    final last = _progress.lastNumberSession();
    if (last == null) return false;
    return last.avg2DigitsMs < _kAdaptiveMaxMs &&
        last.hit2DigitsPct >= _kAdaptiveMinHitPct;
  }

  int _digitsForTrial(int index) {
    // index es 0-based.
    if (_adaptiveStart) {
      // 1–6 → 2 cifras, 7–10 → 3 cifras.
      return index < 6 ? 2 : 3;
    }
    // 1–3 → 1 cifra, 4–7 → 2 cifras, 8–10 → 3 cifras.
    if (index < 3) return 1;
    if (index < 7) return 2;
    return 3;
  }

  ({int minV, int maxV}) _rangeForDigits(int digits) {
    switch (digits) {
      case 1:
        return (minV: 1, maxV: 9);
      case 2:
        return (minV: 10, maxV: 99);
      case 3:
      default:
        return (minV: 100, maxV: 999);
    }
  }

  void _prepareTrial() {
    final digits = _digitsForTrial(_trialIndex);
    final range = _rangeForDigits(digits);
    final span = range.maxV - range.minV + 1;

    int a = range.minV + _rng.nextInt(span);
    int b = range.minV + _rng.nextInt(span);
    // Garantizar distancia >= 2.
    while ((a - b).abs() < 2) {
      b = range.minV + _rng.nextInt(span);
    }

    final mayor = _rng.nextBool();
    // Colocación aleatoria izquierda/derecha.
    final leftIsA = _rng.nextBool();

    _current = _Trial(
      left: leftIsA ? a : b,
      right: leftIsA ? b : a,
      conditionMayor: mayor,
      digits: digits,
    );

    _stopwatch.reset();
    _lastTapWasLeft = null;
    _phase = _Phase.prep;
    setState(() {});
  }

  // --- Flujo del ensayo -----------------------------------------------------

  void _startTrial() {
    _stopwatch
      ..reset()
      ..start();
    setState(() => _phase = _Phase.trial);
  }

  Future<void> _onTap(bool tappedLeft) async {
    if (_phase != _Phase.trial) return;
    _stopwatch.stop();
    final latency = _stopwatch.elapsedMilliseconds;

    final correct = tappedLeft == _current.isLeftCorrect();
    final settings = context.read<SettingsProvider>();
    if (correct) {
      settings.hapticSuccess(); // vibración corta
    } else {
      settings.hapticError(); // vibración larga
    }

    _latencies.add(latency);
    _trialDigits.add(_current.digits);
    _trialHits.add(correct);

    setState(() {
      _lastTapWasLeft = tappedLeft;
      _lastTapCorrect = correct;
      _phase = _Phase.feedback;
    });

    // Feedback inmediato ~400 ms (no cuenta en la latencia).
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _advance();
  }

  void _advance() {
    if (_trialIndex >= _totalTrials - 1) {
      _finish();
      return;
    }
    _trialIndex++;
    _prepareTrial();
  }

  // --- Cálculo de métricas y fin (§7.4) -------------------------------------

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;

    final n = _latencies.length;
    final avg = n == 0
        ? 0.0
        : _latencies.reduce((a, b) => a + b) / n;
    final variance = n == 0
        ? 0.0
        : _latencies
                .map((l) => (l - avg) * (l - avg))
                .reduce((a, b) => a + b) /
            n;
    final std = sqrt(variance);

    int hits = 0, hits1 = 0, hits2 = 0, hits3 = 0;
    final twoDigitLat = <int>[];
    int twoDigitCount = 0, twoDigitHits = 0;
    for (int i = 0; i < n; i++) {
      final hit = _trialHits[i];
      if (hit) hits++;
      switch (_trialDigits[i]) {
        case 1:
          if (hit) hits1++;
          break;
        case 2:
          twoDigitCount++;
          twoDigitLat.add(_latencies[i]);
          if (hit) {
            hits2++;
            twoDigitHits++;
          }
          break;
        case 3:
          if (hit) hits3++;
          break;
      }
    }
    final avg2 = twoDigitLat.isEmpty
        ? 0.0
        : twoDigitLat.reduce((a, b) => a + b) / twoDigitLat.length;
    final hit2Pct =
        twoDigitCount == 0 ? 0.0 : (twoDigitHits / twoDigitCount) * 100.0;

    final session = NumberSession(
      dateIso: _progress.todayIso(),
      avgReactionMs: double.parse(avg.toStringAsFixed(1)),
      stdReactionMs: double.parse(std.toStringAsFixed(1)),
      hits: hits,
      hits1: hits1,
      hits2: hits2,
      hits3: hits3,
      avg2DigitsMs: double.parse(avg2.toStringAsFixed(1)),
      hit2DigitsPct: double.parse(hit2Pct.toStringAsFixed(1)),
    );
    final outcome = _progress.compareNumber(session);
    await _progress.saveNumberSession(session);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ActivityResultScreen(
          title: 'Mayor o menor',
          metrics: [
            'Tiempo medio: ${session.avgReactionMs.round()} ms',
            'Aciertos: $hits de $_totalTrials',
          ],
          outcome: outcome,
          message: _progress.messageFor(outcome),
        ),
      ),
    );
  }

  // --- Pausa ----------------------------------------------------------------

  void _openPause() {
    if (_stopwatch.isRunning) _stopwatch.stop();
    setState(() => _paused = true);
  }

  void _resume() {
    // Reanuda el cronómetro solo si estábamos en mitad de un ensayo.
    if (_phase == _Phase.trial) _stopwatch.start();
    setState(() => _paused = false);
  }

  Future<void> _howToPlay() => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ActivityTutorialScreen(
            tutorial: numberTutorial,
            reviewMode: true,
          ),
        ),
      );

  Future<void> _openSettings() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );

  void _exitToMenu() => Navigator.of(context).popUntil((r) => r.isFirst);

  // --- UI -------------------------------------------------------------------

  String get _instruction =>
      _current.conditionMayor ? 'Toca el número MAYOR' : 'Toca el número MENOR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPaddingH,
                vertical: AppDimens.screenPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ActivityTopBar(
                    title: 'Mayor o menor',
                    onBack: () => Navigator.of(context).pop(),
                    onPause: _openPause,
                  ),
                  const SizedBox(height: 12),
                  ProgressIndicatorText(
                    current: _trialIndex + 1,
                    total: _totalTrials,
                    prefix: 'Ronda',
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildPhase()),
                ],
              ),
            ),
            if (_paused)
              PauseOverlay(
                onContinue: _resume,
                onHowToPlay: _howToPlay,
                onSettings: _openSettings,
                onExitToMenu: _exitToMenu,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case _Phase.prep:
        return _buildPrep();
      case _Phase.trial:
        return _buildTrial(interactive: true);
      case _Phase.feedback:
        return _buildTrial(interactive: false);
    }
  }

  Widget _buildPrep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Text(
          'Prepárate',
          textAlign: TextAlign.center,
          style: AppTextStyles.h2.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          ),
          child: Text(
            _instruction,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Cuando toques «Listo» aparecerán dos números. '
          'Tócalo lo antes posible.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
        const Spacer(),
        PrimaryButton(
          label: 'Listo',
          icon: Icons.play_arrow_outlined,
          onPressed: _startTrial,
        ),
      ],
    );
  }

  Widget _buildTrial({required bool interactive}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _instruction,
          textAlign: TextAlign.center,
          style: AppTextStyles.h2.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _NumberButton(
                  value: _current.left,
                  onTap: interactive ? () => _onTap(true) : null,
                  showFeedback: _lastTapWasLeft == true,
                  feedbackCorrect: _lastTapCorrect,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _NumberButton(
                  value: _current.right,
                  onTap: interactive ? () => _onTap(false) : null,
                  showFeedback: _lastTapWasLeft == false,
                  feedbackCorrect: _lastTapCorrect,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Botón grande con un número. Muestra ✓/✕ superpuesto en el feedback,
/// nunca solo por color (icono + color).
class _NumberButton extends StatelessWidget {
  final int value;
  final VoidCallback? onTap;
  final bool showFeedback;
  final bool feedbackCorrect;

  const _NumberButton({
    required this.value,
    required this.onTap,
    required this.showFeedback,
    required this.feedbackCorrect,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.surface;
    Color border = AppColors.primary;
    Color textColor = AppColors.primary;
    if (showFeedback) {
      final fb = feedbackCorrect ? AppColors.success : AppColors.error;
      bg = fb;
      border = fb;
      textColor = AppColors.onPrimary;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      elevation: AppDimens.cardElevation,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppDimens.minTouch,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.cardRadius),
            border: Border.all(color: border, width: 2),
          ),
          alignment: Alignment.center,
          child: showFeedback
              ? Icon(
                  feedbackCorrect
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: AppColors.onPrimary,
                  size: 56,
                )
              : Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}