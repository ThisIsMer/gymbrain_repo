import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/activity_tutorials.dart';
import '../data/sentence_bank.dart';
import '../models/sentence_item.dart';
import '../models/sentence_session.dart';
import '../services/progress_service.dart';
import '../services/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/feedback_badge.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_indicator_text.dart';
import 'activity_result_screen.dart';
import 'activity_tutorial_screen.dart';
import 'settings_screen.dart';

enum _Phase { study, build, correct, incorrect }

class _Token {
  final int id;
  final String word;
  const _Token(this.id, this.word);
}

const int _totalSentences = 10;

/// Demo 2 — Reconstruye la frase (§6).
class SentenceGameScreen extends StatefulWidget {
  const SentenceGameScreen({super.key});

  @override
  State<SentenceGameScreen> createState() => _SentenceGameScreenState();
}

class _SentenceGameScreenState extends State<SentenceGameScreen> {
  final Random _rng = Random();
  late final ProgressService _progress;

  int _sentenceIndex = 0; // 0-based, juega 10
  int _aciertosConsecutivos = 0;
  int _nivelLongitud = 1;

  int _correctSentences = 0;
  int _totalWordsPresented = 0;
  int _totalWordsCorrect = 0;
  int _maxSentenceLength = 0;

  final Set<String> _usedThisSession = {};

  late SentenceItem _current;
  late List<_Token> _allTokens;
  final List<int> _placedIds = [];

  _Phase _phase = _Phase.study;
  bool _paused = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _progress = context.read<ProgressService>();
    _loadSentence();
  }

  // --- Selección de frase (§6.2) -------------------------------------------

  SentenceItem _pickSentence(int nivel) {
    final levelItems = sentencesOfLevel(nivel);
    final levelIds = levelItems.map((e) => e.id).toList();
    final seen = _progress.seenSentenceIds().toSet();

    var candidates = levelItems
        .where((s) => !_usedThisSession.contains(s.id) && !seen.contains(s.id))
        .toList();

    if (candidates.isEmpty) {
      // Si se ha agotado >= 80% del nivel, reiniciar su set de vistas.
      final seenInLevel = levelIds.where(seen.contains).length;
      if (levelIds.isNotEmpty && seenInLevel >= (0.8 * levelIds.length)) {
        _progress.resetSeenForLevel(nivel, levelIds);
      }
      candidates =
          levelItems.where((s) => !_usedThisSession.contains(s.id)).toList();
    }
    if (candidates.isEmpty) candidates = List.of(levelItems);

    return candidates[_rng.nextInt(candidates.length)];
  }

  void _loadSentence() {
    _current = _pickSentence(_nivelLongitud);
    _usedThisSession.add(_current.id);
    _progress.markSentenceSeen(_current.id);

    final words = _current.palabras;
    _maxSentenceLength = max(_maxSentenceLength, words.length);

    // Construir tokens: palabras + trampas + intercambiables, barajados.
    final options = _current.buildOptions()..shuffle(_rng);
    _allTokens = [
      for (int i = 0; i < options.length; i++) _Token(i, options[i]),
    ];
    _placedIds.clear();
    _phase = _Phase.study;
    setState(() {});
  }

  // --- Construcción ---------------------------------------------------------

  List<_Token> get _placed =>
      _placedIds.map((id) => _allTokens.firstWhere((t) => t.id == id)).toList();

  // Reparte las palabras colocadas en hasta 3 filas, manteniendo el orden.
  List<List<_Token>> get _placedRows {
    final tokens = _placed;
    if (tokens.isEmpty) return [];
    const maxPerRow = 4;
    final rowCount =
        min(3, (tokens.length / maxPerRow).ceil()).clamp(1, 3);
    final perRow = (tokens.length / rowCount).ceil();
    return [
      for (int i = 0; i < tokens.length; i += perRow)
        tokens.sublist(i, min(i + perRow, tokens.length)),
    ];
  }

  void _place(_Token t) {
    if (_phase != _Phase.build) return;
    context.read<SettingsProvider>().hapticLight();
    setState(() => _placedIds.add(t.id));
  }

  void _unplace(_Token t) {
    if (_phase != _Phase.build) return;
    context.read<SettingsProvider>().hapticLight();
    setState(() => _placedIds.remove(t.id));
  }

  void _startBuild() {
    setState(() => _phase = _Phase.build);
  }

  // --- Evaluación (§6.5) ----------------------------------------------------

  Future<void> _confirm() async {
    final settings = context.read<SettingsProvider>();
    final target = _current.palabras;
    final built = _placed.map((t) => t.word).toList();

    // Acumular % de palabras en posición correcta.
    _totalWordsPresented += target.length;
    final n = min(target.length, built.length);
    for (int i = 0; i < n; i++) {
      if (built[i] == target[i]) _totalWordsCorrect++;
    }

    final isCorrect = built.length == target.length &&
        List.generate(target.length, (i) => built[i] == target[i])
            .every((e) => e);

    if (isCorrect) {
      settings.hapticSuccess();
      _correctSentences++;
      _aciertosConsecutivos++;
      setState(() => _phase = _Phase.correct);
      if (_aciertosConsecutivos >= 3 && _nivelLongitud < 4) {
        _nivelLongitud++;
        _aciertosConsecutivos = 0;
      }
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      _advance();
    } else {
      settings.hapticError();
      _aciertosConsecutivos = 0; // mantiene nivel
      setState(() => _phase = _Phase.incorrect);
      // Permanece hasta que el usuario pulse "Continuar".
    }
  }

  void _advance() {
    if (_sentenceIndex >= _totalSentences - 1) {
      _finish();
      return;
    }
    setState(() => _sentenceIndex++);
    _loadSentence();
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;

    final pct = _totalWordsPresented == 0
        ? 0.0
        : (_totalWordsCorrect / _totalWordsPresented) * 100.0;

    final session = SentenceSession(
      dateIso: _progress.todayIso(),
      correctSentences: _correctSentences,
      wordsCorrectPercent: double.parse(pct.toStringAsFixed(1)),
      maxSentenceLength: _maxSentenceLength,
    );
    final outcome = _progress.compareSentence(session);
    await _progress.saveSentenceSession(session);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ActivityResultScreen(
          title: 'Reconstruye la frase',
          metrics: [
            'Frases correctas: $_correctSentences de $_totalSentences',
            'Palabras bien colocadas: ${session.wordsCorrectPercent.round()}%',
          ],
          outcome: outcome,
          message: _progress.messageFor(outcome),
        ),
      ),
    );
  }

  // --- Pausa ----------------------------------------------------------------

  void _openPause() => setState(() => _paused = true);
  void _resume() => setState(() => _paused = false);

  Future<void> _howToPlay() => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ActivityTutorialScreen(
            tutorial: sentenceTutorial,
            reviewMode: true,
          ),
        ),
      );

  Future<void> _openSettings() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );

  void _exitToMenu() => Navigator.of(context).popUntil((r) => r.isFirst);

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
                  Row(
                    children: [
                      Expanded(
                        child: ProgressIndicatorText(
                          current: _sentenceIndex + 1,
                          total: _totalSentences,
                          prefix: 'Frase',
                        ),
                      ),
                      IconButton(
                        onPressed: _openPause,
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
      case _Phase.study:
        return _buildStudy();
      case _Phase.build:
        return _buildConstruction(showConfirm: true);
      case _Phase.correct:
        return _buildConstruction(showConfirm: false, banner: _correctBanner());
      case _Phase.incorrect:
        return _buildIncorrect();
    }
  }

  Widget _sentenceStrip(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Text(
        text,
        style: AppTextStyles.h2.copyWith(color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildStudy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Memoriza la siguiente frase', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        _sentenceStrip(_current.texto),
        const Spacer(),
        PrimaryButton(
          label: 'Listo',
          icon: Icons.visibility_off_outlined,
          onPressed: _startBuild,
        ),
      ],
    );
  }

  Widget _correctBanner() => const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: FeedbackBadge(success: true, label: '¡Muy bien!'),
      );

  Widget _buildConstruction({required bool showConfirm, Widget? banner}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Ordena las palabras de la frase', style: AppTextStyles.body),
        const SizedBox(height: 12),
        if (banner != null) banner,
        // Zona de construcción.
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.cardRadius),
            border: Border.all(color: AppColors.hairline),
          ),
          child: _placed.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Toca las palabras para construir la frase.',
                      style: AppTextStyles.caption),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final row in _placedRows)
                      Row(
                        children: [
                          for (final t in row)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: _WordChip(
                                  word: t.word,
                                  state: _ChipState.filled,
                                  onTap: () => _unplace(t),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        // Cuadrícula de opciones (máx 2 columnas).
        Expanded(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const gap = 10.0;
                final itemWidth = (constraints.maxWidth - gap) / 2;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final t in _allTokens)
                      SizedBox(
                        width: itemWidth,
                        child: _placedIds.contains(t.id)
                            ? _WordChip(
                                word: t.word,
                                state: _ChipState.used,
                                onTap: () => _unplace(t),
                              )
                            : _WordChip(
                                word: t.word,
                                state: _ChipState.normal,
                                onTap: () => _place(t),
                              ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (showConfirm)
          PrimaryButton(
            label: 'Confirmar',
            icon: Icons.check,
            onPressed: _placed.isEmpty ? null : _confirm,
          ),
      ],
    );
  }

  Widget _buildIncorrect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FeedbackBadge(success: false, label: 'Casi. La frase era:'),
        const SizedBox(height: 16),
        _sentenceStrip(_current.texto),
        const Spacer(),
        PrimaryButton(
          label: 'Continuar',
          icon: Icons.arrow_forward,
          onPressed: _advance,
        ),
      ],
    );
  }
}

enum _ChipState { normal, used, filled }

class _WordChip extends StatelessWidget {
  final String word;
  final _ChipState state;
  final VoidCallback onTap;
  const _WordChip(
      {required this.word, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    final Color border;
    switch (state) {
      case _ChipState.filled:
        background = AppColors.primary;
        foreground = AppColors.onPrimary;
        border = AppColors.primary;
        break;
      case _ChipState.used:
        background = AppColors.hairline;
        foreground = AppColors.textMain.withValues(alpha: 0.4);
        border = AppColors.hairline;
        break;
      case _ChipState.normal:
        background = AppColors.surface;
        foreground = AppColors.primary;
        border = AppColors.primary;
        break;
    }
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: 1),
          ),
          child: Text(
            word,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}