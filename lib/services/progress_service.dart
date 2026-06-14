import 'dart:math';

import '../data/daily_questions.dart';
import '../data/health_tips.dart';
import '../data/result_messages.dart';
import '../models/daily_answer.dart';
import '../models/memory_session.dart';
import '../models/number_session.dart';
import '../models/sentence_session.dart';
import '../models/streak_data.dart';
import 'storage_service.dart';

/// Resultado de comparar una sesión con el historial (§9), para el mensaje.
enum ComparisonOutcome { firstTime, improved, neutral }

class ProgressService {
  ProgressService(this._storage);

  final StorageService _storage;
  final Random _rng = Random();

  // --- Helpers de fecha (yyyy-MM-dd) ---------------------------------------

  String _iso(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String todayIso() => _iso(DateTime.now());
  String _isoOffset(int daysAgo) =>
      _iso(DateTime.now().subtract(Duration(days: daysAgo)));

  // --- Onboarding -----------------------------------------------------------

  bool get onboardingDone =>
      _storage.getBool(StorageService.kOnboardingDone, defaultValue: false);

  Future<void> setOnboardingDone() async {
    await _storage.setBool(StorageService.kOnboardingDone, true);
  }

  // --- Tutoriales por actividad ---------------------------------------------

  /// ¿Se ha visto ya el tutorial de la actividad [id]?
  bool tutorialSeen(String id) =>
      _storage.getStringList(StorageService.kTutorialsSeen).contains(id);

  /// Marca el tutorial de la actividad [id] como visto (idempotente).
  Future<void> markTutorialSeen(String id) async {
    final seen = _storage.getStringList(StorageService.kTutorialsSeen);
    if (!seen.contains(id)) {
      seen.add(id);
      await _storage.setStringList(StorageService.kTutorialsSeen, seen);
    }
  }

  // --- Racha ----------------------------------------------------------------

  StreakData loadStreak() {
    final json = _storage.getJsonMap(StorageService.kStreak);
    return json != null ? StreakData.fromJson(json) : StreakData.empty();
  }

  Future<void> _saveStreak(StreakData s) async {
    await _storage.setJsonMap(StorageService.kStreak, s.toJson());
  }

  /// ¿Ya se completó la rutina de hoy?
  bool dailyDoneToday() => loadStreak().lastDayIso == todayIso();

  /// Aplica la lógica de racha (§3.3) al completar la rutina del día.
  /// Si [forgot] es true (se pulsó "No lo sé" en alguna pregunta), la racha
  /// se reinicia. Devuelve la racha resultante (para la pantalla de resultado).
  Future<StreakData> completeDailyRoutine({bool forgot = false}) async {
    final s = loadStreak();
    final today = todayIso();
    final yesterday = _isoOffset(1);

    if (s.lastDayIso == today) {
      return s; // ya contó hoy
    } else if (forgot) {
      s.current = 0;
      s.consecutiveDays = 0;
    } else if (s.lastDayIso == yesterday) {
      s.current += 1;
      s.consecutiveDays += 1;
    } else {
      s.current = 1;
      s.consecutiveDays = 1;
    }
    s.max = max(s.max, s.current);
    s.lastDayIso = today;
    await _saveStreak(s);
    return s;
  }

  // --- Preguntas diarias ----------------------------------------------------

  List<DailyAnswer> loadDailyAnswers() {
    return _storage
        .getJsonList(StorageService.kDailyAnswers)
        .map(DailyAnswer.fromJson)
        .toList();
  }

  Future<void> saveDailyAnswer(DailyAnswer answer) async {
    final list = loadDailyAnswers();
    // Reemplaza si ya existe respuesta para ese día/pregunta.
    list.removeWhere(
      (a) => a.dayIso == answer.dayIso && a.questionId == answer.questionId,
    );
    list.add(answer);
    await _storage.setJsonList(
      StorageService.kDailyAnswers,
      list.map((a) => a.toJson()).toList(),
    );
  }

  /// Nº de preguntas diarias ya respondidas hoy (0..3).
  int answeredTodayCount() {
    final today = todayIso();
    final count = loadDailyAnswers().where((a) => a.dayIso == today).length;
    return count.clamp(0, 3);
  }

  /// Profundidad temporal de las preguntas de hoy (§8.2). Cap a 3.
  int currentDepth() {
    final consec = loadStreak().consecutiveDays;
    final depth = 1 + (consec ~/ 3);
    return depth.clamp(1, 3);
  }

  /// Resuelve las 3 preguntas del día según la profundidad (§8.2).
  /// Reparto: depth1 = 3 hoy; depth2 = 1 hoy + 2 ayer; depth3 = 1 hoy + 1 ayer
  /// + 1 anteayer.
  List<ResolvedQuestion> resolveDailyQuestions() {
    final depth = currentDepth();
    final wakeup = dailyQuestionDefs[0];
    final lunch = dailyQuestionDefs[1];
    final afternoon = dailyQuestionDefs[2];

    String textFor(DailyQuestionDef def, int offset) {
      switch (offset) {
        case 2:
          return def.dayBefore;
        case 1:
          return def.yesterday;
        case 0:
        default:
          return def.today;
      }
    }

    final List<int> offsets;
    switch (depth) {
      case 3:
        offsets = [0, 1, 2];
        break;
      case 2:
        offsets = [0, 1, 1];
        break;
      case 1:
      default:
        offsets = [0, 0, 0];
    }

    final defs = [wakeup, lunch, afternoon];
    return List.generate(3, (i) {
      return ResolvedQuestion(
        questionId: defs[i].id,
        text: textFor(defs[i], offsets[i]),
        dayOffset: offsets[i],
      );
    });
  }

  /// Contraste retrospectivo suave (§8.3): respuesta guardada de un día
  /// pasado, si existe y fue recordada con texto.
  String? retrospectiveHint(String questionId, int dayOffset) {
    if (dayOffset == 0) return null;
    final targetIso = _isoOffset(dayOffset);
    final answers = loadDailyAnswers();
    for (final a in answers) {
      if (a.dayIso == targetIso &&
          a.questionId == questionId &&
          a.remembered &&
          (a.text?.trim().isNotEmpty ?? false)) {
        return 'El otro día anotaste: «${a.text!.trim()}».';
      }
    }
    return null;
  }

  // --- Sesiones: Memory -----------------------------------------------------

  List<MemorySession> loadMemorySessions() {
    return _storage
        .getJsonList(StorageService.kSessionsMemory)
        .map(MemorySession.fromJson)
        .toList();
  }

  Future<void> saveMemorySession(MemorySession s) async {
    final list = loadMemorySessions()..add(s);
    await _storage.setJsonList(
      StorageService.kSessionsMemory,
      list.map((e) => e.toJson()).toList(),
    );
  }

  // --- Sesiones: Sentence ---------------------------------------------------

  List<SentenceSession> loadSentenceSessions() {
    return _storage
        .getJsonList(StorageService.kSessionsSentence)
        .map(SentenceSession.fromJson)
        .toList();
  }

  Future<void> saveSentenceSession(SentenceSession s) async {
    final list = loadSentenceSessions()..add(s);
    await _storage.setJsonList(
      StorageService.kSessionsSentence,
      list.map((e) => e.toJson()).toList(),
    );
  }

  // --- Sesiones: Number -----------------------------------------------------

  List<NumberSession> loadNumberSessions() {
    return _storage
        .getJsonList(StorageService.kSessionsNumber)
        .map(NumberSession.fromJson)
        .toList();
  }

  Future<void> saveNumberSession(NumberSession s) async {
    final list = loadNumberSessions()..add(s);
    await _storage.setJsonList(
      StorageService.kSessionsNumber,
      list.map((e) => e.toJson()).toList(),
    );
  }

  /// Última sesión de números (para arranque adaptativo, §7.1).
  NumberSession? lastNumberSession() {
    final list = loadNumberSessions();
    return list.isEmpty ? null : list.last;
  }

  // --- Frases vistas (no repetir hasta agotar 80% del nivel, §6.2) ----------

  List<String> seenSentenceIds() =>
      _storage.getStringList(StorageService.kSentenceSeenIds);

  Future<void> markSentenceSeen(String id) async {
    final list = seenSentenceIds();
    if (!list.contains(id)) {
      list.add(id);
      await _storage.setStringList(StorageService.kSentenceSeenIds, list);
    }
  }

  Future<void> resetSeenForLevel(int nivel, List<String> levelIds) async {
    final list = seenSentenceIds()
      ..removeWhere((id) => levelIds.contains(id));
    await _storage.setStringList(StorageService.kSentenceSeenIds, list);
  }

  // --- Comparación y mensajes de resultado (§9) -----------------------------

  /// Mensaje aleatorio de una lista.
  String _pick(List<String> list) => list[_rng.nextInt(list.length)];

  String randomHealthTip() => _pick(healthTips);

  String messageFor(ComparisonOutcome outcome) {
    switch (outcome) {
      case ComparisonOutcome.firstTime:
        return ResultMessages.firstTime;
      case ComparisonOutcome.improved:
        return _pick(ResultMessages.improved);
      case ComparisonOutcome.neutral:
        // Ocasionalmente un consejo de salud.
        if (_rng.nextBool()) return _pick(ResultMessages.neutral);
        return randomHealthTip();
    }
  }

  /// Memory: menor tiempo = mejor, frente al mejor previo del MISMO nivel.
  ComparisonOutcome compareMemory(MemorySession current) {
    final previous = loadMemorySessions()
        .where((s) =>
            s.difficulty == current.difficulty && s.dateIso != current.dateIso)
        .toList();
    // Excluir la sesión actual si ya está guardada (comparar contra el resto).
    final others = loadMemorySessions()
        .where((s) => s.difficulty == current.difficulty)
        .toList();
    others.remove(current);
    final pool = previous.isNotEmpty ? previous : others;
    if (pool.isEmpty) return ComparisonOutcome.firstTime;
    final bestTime =
        pool.map((s) => s.timeSeconds).reduce((a, b) => a < b ? a : b);
    return current.timeSeconds < bestTime
        ? ComparisonOutcome.improved
        : ComparisonOutcome.neutral;
  }

  /// Sentence: mayor % de palabras = mejor, frente al máximo previo.
  ComparisonOutcome compareSentence(SentenceSession current) {
    final pool = loadSentenceSessions().where((s) => s != current).toList();
    if (pool.isEmpty) return ComparisonOutcome.firstTime;
    final bestPct = pool
        .map((s) => s.wordsCorrectPercent)
        .reduce((a, b) => a > b ? a : b);
    return current.wordsCorrectPercent > bestPct
        ? ComparisonOutcome.improved
        : ComparisonOutcome.neutral;
  }

  /// Number: más aciertos = mejor; con los mismos aciertos, menor tiempo
  /// medio = mejor. Frente a la mejor sesión previa.
  ComparisonOutcome compareNumber(NumberSession current) {
    final pool = loadNumberSessions().where((s) => s != current).toList();
    if (pool.isEmpty) return ComparisonOutcome.firstTime;
    final best = pool.reduce(
        (a, b) => _isBetterNumberSession(b, a) ? b : a);
    return _isBetterNumberSession(current, best)
        ? ComparisonOutcome.improved
        : ComparisonOutcome.neutral;
  }

  /// `true` si [a] es mejor que [b]: prioriza más aciertos y, en caso de
  /// empate, menor tiempo medio de reacción.
  bool _isBetterNumberSession(NumberSession a, NumberSession b) {
    if (a.hits != b.hits) return a.hits > b.hits;
    return a.avgReactionMs < b.avgReactionMs;
  }

  // --- Restablecer progreso -------------------------------------------------

  Future<void> resetAll() async {
    await _storage.clearAll();
  }
}