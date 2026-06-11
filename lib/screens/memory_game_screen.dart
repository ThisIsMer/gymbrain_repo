import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/activity_tutorials.dart';
import '../data/memory_bank.dart';
import '../models/game_difficulty.dart';
import '../models/memory_item.dart';
import '../models/memory_session.dart';
import '../services/progress_service.dart';
import '../services/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/activity_top_bar.dart';
import '../widgets/pause_overlay.dart';
import 'activity_result_screen.dart';
import 'activity_tutorial_screen.dart';
import 'settings_screen.dart';

enum _CardState { down, up, matched, fail }

class _MemoryCard {
  final int position;
  final MemoryItem item;
  _CardState state;
  _MemoryCard(this.position, this.item, this.state);
}

/// Demo 1 — Memory (§5).
class MemoryGameScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  const MemoryGameScreen({super.key, required this.difficulty});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final Random _rng = Random();
  late List<_MemoryCard> _cards;

  int? _first;
  int? _second;
  bool _locked = false;
  int _pairsFound = 0;
  int _failedRevisits = 0;
  final Set<int> _seenPositions = {};

  final Stopwatch _stopwatch = Stopwatch();
  bool _paused = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    // 1. N elementos distintos del banco.
    final pairs = widget.difficulty.pairs;
    final pool = List<MemoryItem>.from(memoryBank)..shuffle(_rng);
    final chosen = pool.take(pairs).toList();

    // 2. Duplicar y barajar.
    final items = <MemoryItem>[];
    for (final it in chosen) {
      items..add(it)..add(it);
    }
    items.shuffle(_rng);

    _cards = List.generate(
      items.length,
      (i) => _MemoryCard(i, items[i], _CardState.down),
    );

    // 3. Reiniciar variables.
    _first = null;
    _second = null;
    _locked = false;
    _pairsFound = 0;
    _failedRevisits = 0;
    _seenPositions.clear();
    _stopwatch
      ..reset()
      ..start();
  }

  bool _isValidTap(int pos) {
    if (_locked || _paused) return false;
    final c = _cards[pos];
    return c.state == _CardState.down;
  }

  Future<void> _onTap(int pos) async {
    if (!_isValidTap(pos)) return;
    final settings = context.read<SettingsProvider>();

    setState(() => _cards[pos].state = _CardState.up);

    if (_first == null) {
      _first = pos;
      return;
    }

    _second = pos;
    setState(() => _locked = true);

    final a = _cards[_first!];
    final b = _cards[_second!];
    final match = a.item.id == b.item.id;

    if (match) {
      settings.hapticSuccess();
      setState(() {
        a.state = _CardState.matched;
        b.state = _CardState.matched;
      });
      _pairsFound++;
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      _seenPositions..add(a.position)..add(b.position);
      _afterTurn();
    } else {
      settings.hapticError();
      // Conteo de revisitas fallidas (§5.3).
      if (_seenPositions.contains(a.position) ||
          _seenPositions.contains(b.position)) {
        _failedRevisits++;
      }
      setState(() {
        a.state = _CardState.fail;
        b.state = _CardState.fail;
      });
      await Future<void>.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;
      setState(() {
        a.state = _CardState.down;
        b.state = _CardState.down;
      });
      _seenPositions..add(a.position)..add(b.position);
      _afterTurn();
    }
  }

  void _afterTurn() {
    if (!mounted) return;
    setState(() {
      _first = null;
      _second = null;
      _locked = false;
    });
    if (_pairsFound == widget.difficulty.pairs) {
      _finish();
    }
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    _stopwatch.stop();
    final seconds = _stopwatch.elapsed.inSeconds;

    final progress = context.read<ProgressService>();
    final session = MemorySession(
      dateIso: progress.todayIso(),
      difficulty: widget.difficulty.key,
      timeSeconds: seconds,
      failedRevisits: _failedRevisits,
    );
    final outcome = progress.compareMemory(session);
    await progress.saveMemorySession(session);

    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    final metrics = <String>[
      'Tiempo: $mm:$ss',
      _failedRevisits == 0
          ? '¡Partida perfecta!'
          : 'Fallos: $_failedRevisits',
    ];

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ActivityResultScreen(
          title: 'Memoria visual',
          metrics: metrics,
          outcome: outcome,
          message: progress.messageFor(outcome),
        ),
      ),
    );
  }

  // --- Pausa ----------------------------------------------------------------

  void _openPause() {
    setState(() {
      _paused = true;
      _stopwatch.stop();
    });
  }

  void _resume() {
    setState(() {
      _paused = false;
      if (!_finished) _stopwatch.start();
    });
  }

  Future<void> _howToPlay() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActivityTutorialScreen(
          tutorial: memoryTutorial,
          reviewMode: true,
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _exitToMenu() {
    // Cancela sin guardar.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

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
                children: [
                  ActivityTopBar(
                    title: 'Memoria visual',
                    onBack: () => Navigator.of(context).pop(),
                    onPause: _openPause,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Encuentra las parejas', style: AppTextStyles.h2),
                      ),
                      Text(
                        '$_pairsFound de ${widget.difficulty.pairs}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _pairsFound / widget.difficulty.pairs,
                      minHeight: 8,
                      backgroundColor: AppColors.hairline,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildGrid()),
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

  Widget _buildGrid() {
    final cols = widget.difficulty.columns;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _cards.length,
      itemBuilder: (_, i) => _CardTile(
        card: _cards[i],
        onTap: () => _onTap(i),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final _MemoryCard card;
  final VoidCallback onTap;
  const _CardTile({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final down = card.state == _CardState.down;

    Color bg;
    switch (card.state) {
      case _CardState.down:
        bg = AppColors.primary;
        break;
      case _CardState.matched:
        bg = AppColors.success.withValues(alpha: 0.12);
        break;
      case _CardState.fail:
        bg = AppColors.error.withValues(alpha: 0.12);
        break;
      case _CardState.up:
        bg = AppColors.surface;
        break;
    }

    return Semantics(
      button: true,
      label: down ? 'Tarjeta boca abajo' : card.item.nombre,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedSwitcher(
          duration: AppDimens.navTransition,
          child: Container(
            key: ValueKey(card.state),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDimens.cardRadius),
              border: card.state == _CardState.matched
                  ? Border.all(color: AppColors.success, width: 2)
                  : card.state == _CardState.fail
                      ? Border.all(color: AppColors.error, width: 2)
                      : null,
              boxShadow: const [
                BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
              ],
            ),
            child: down ? null : _buildFace(),
          ),
        ),
      ),
    );
  }

  Widget _buildFace() {
    final overlay = card.state == _CardState.matched
        ? const Icon(Icons.check_circle, color: AppColors.success, size: 28)
        : card.state == _CardState.fail
            ? const Icon(Icons.cancel, color: AppColors.error, size: 28)
            : null;

    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/images/${card.item.id}.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) {
                // Fallback: nombre del elemento en Nunito Bold.
                return Center(
                  child: Text(
                    card.item.nombre,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (overlay != null)
          Positioned(top: 4, right: 4, child: overlay),
      ],
    );
  }
}