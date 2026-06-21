import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/daily_questions.dart';
import '../models/daily_answer.dart';
import '../models/streak_data.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import 'daily_result_screen.dart';

/// Preguntas diarias (§8). 3 o más preguntas según la racha; "No lo sé" en
/// cualquiera de ellas reinicia la racha diaria.
class DailyQuestionsScreen extends StatefulWidget {
  const DailyQuestionsScreen({super.key});

  @override
  State<DailyQuestionsScreen> createState() => _DailyQuestionsScreenState();
}

class _DailyQuestionsScreenState extends State<DailyQuestionsScreen> {
  late final ProgressService _progress;
  late final List<ResolvedQuestion> _questions;
  final TextEditingController _controller = TextEditingController();
  int _index = 0;
  bool _forgotAny = false;

  @override
  void initState() {
    super.initState();
    _progress = context.read<ProgressService>();
    _questions = _progress.resolveDailyQuestions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ResolvedQuestion get _current => _questions[_index];

  Future<void> _save({required bool remembered}) async {
    if (!remembered) _forgotAny = true;
    final text = remembered ? _controller.text.trim() : null;
    final answer = DailyAnswer(
      dayIso: _progress.todayIso(),
      questionId: _current.questionId,
      text: (text != null && text.isEmpty) ? null : text,
      remembered: remembered,
    );
    await _progress.saveDailyAnswer(answer);

    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _controller.clear();
      });
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final alreadyDone = _progress.dailyDoneToday();
    final StreakData streak =
        await _progress.completeDailyRoutine(forgot: _forgotAny);
    final isBest =
        !_forgotAny && streak.current >= streak.max && !alreadyDone;

    // Mensaje: positivo + (ocasional) consejo de salud.
    final tip = _progress.randomHealthTip();
    final message = isBest
        ? 'Has cuidado tu memoria un día más. $tip'
        : 'Lo importante es la constancia. $tip';

    final today = _progress.todayIso();
    final hits = _progress
        .loadDailyAnswers()
        .where((a) => a.dayIso == today && a.remembered)
        .length;

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DailyResultScreen(
          streakDays: streak.current,
          isBest: isBest,
          failed: _forgotAny,
          message: message,
          hits: hits,
          total: _questions.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _controller.text.trim().isNotEmpty;

    return AppScaffold(
      title: 'Racha diaria',
      actions: [
        Text(
          '${_index + 1} / ${_questions.length}',
          style: AppTextStyles.caption,
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_index + 1) / _questions.length,
                minHeight: 8,
                backgroundColor: AppColors.hairline,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PREGUNTA ${_index + 1}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMain.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_current.text, style: AppTextStyles.h2),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu respuesta',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMain.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              minLines: 2,
              maxLines: 4,
              style: AppTextStyles.body,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Escribe tu respuesta…',
                hintStyle: AppTextStyles.body
                    .copyWith(color: AppColors.textMain.withValues(alpha: 0.4)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.all(16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.hairline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Continuar',
              icon: Icons.check,
              onPressed: canConfirm ? () => _save(remembered: true) : null,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'No lo sé',
              icon: Icons.help_outline,
              outlined: true,
              onPressed: () => _save(remembered: false),
            ),
          ],
        ),
      ),
    );
  }
}
