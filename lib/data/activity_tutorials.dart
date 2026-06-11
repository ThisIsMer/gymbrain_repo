import 'package:flutter/material.dart';

import '../models/activity_tutorial.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Tutoriales por actividad (Anexo 1: "comportamiento del tutorial por
/// actividad"; Anexo 6: instrucciones progresivas con ejemplo en pantalla).
///
/// Cada tutorial tiene exactamente 3 páginas. El texto está redactado a
/// partir de las mecánicas reales de cada pantalla de juego.

// Identificadores estables (se persisten en almacenamiento; no traducir).
const String kTutMemory = 'memory';
const String kTutSentence = 'sentence';
const String kTutNumber = 'number';
const String kTutDaily = 'daily';

/// Demo 1 — Memory (§5).
final ActivityTutorial memoryTutorial = ActivityTutorial(
  id: kTutMemory,
  title: 'Memoria visual',
  pages: [
    TutorialPage(
      icon: Icons.grid_view_outlined,
      title: 'Encuentra las parejas',
      body: 'Verás varias tarjetas boca abajo. Detrás hay imágenes que se '
          'repiten formando parejas. Tu objetivo es encontrarlas todas.',
      example: (_) => const _MemoryExample(),
    ),
    const TutorialPage(
      icon: Icons.touch_app_outlined,
      title: 'Toca dos tarjetas',
      body: 'Toca una tarjeta para descubrirla y luego otra. Si las dos '
          'imágenes coinciden, se quedan descubiertas. Si no, se vuelven a '
          'tapar: recuerda dónde estaban.',
    ),
    const TutorialPage(
      icon: Icons.spa_outlined,
      title: 'Sin prisa',
      body: 'No hay tiempo límite, tómate el que necesites. Antes de empezar '
          'puedes elegir el nivel: Fácil, Normal o Difícil.',
    ),
  ],
);

/// Demo 2 — Reconstruye la frase (§6).
final ActivityTutorial sentenceTutorial = ActivityTutorial(
  id: kTutSentence,
  title: 'Simón dice',
  pages: [
    const TutorialPage(
      icon: Icons.menu_book_outlined,
      title: 'Memoriza la frase',
      body: 'Primero aparecerá una frase completa durante unos segundos. '
          'Léela con atención e intenta recordarla.',
    ),
    TutorialPage(
      icon: Icons.touch_app_outlined,
      title: 'Ordena las palabras',
      body: 'La frase desaparece y verás sus palabras desordenadas, junto con '
          'alguna palabra de más. Tócalas en el orden correcto para '
          'reconstruirla.',
      example: (_) => const _SentenceExample(),
    ),
    const TutorialPage(
      icon: Icons.trending_up_outlined,
      title: 'Confirma y avanza',
      body: 'Pulsa "Confirmar" cuando termines. Si te equivocas, podrás verlo '
          'y continuar. Cuantas más aciertes, más largas serán las frases.',
    ),
  ],
);

/// Demo 3 — Mayor o menor (§7).
final ActivityTutorial numberTutorial = ActivityTutorial(
  id: kTutNumber,
  title: 'Mayor o menor',
  pages: [
    TutorialPage(
      icon: Icons.compare_arrows_outlined,
      title: 'Elige el número',
      body: 'Aparecerán dos números, uno a cada lado. Tendrás que tocar el '
          'que se te pida.',
      example: (_) => const _NumberExample(),
    ),
    const TutorialPage(
      icon: Icons.swap_horiz_outlined,
      title: 'Lee bien la consigna',
      body: 'Unas veces te pedirán el número MAYOR y otras el MENOR. Fíjate '
          'en lo que pide arriba antes de tocar.',
    ),
    const TutorialPage(
      icon: Icons.bolt_outlined,
      title: 'Rápido, pero con calma',
      body: 'Responde lo más rápido que puedas sin equivocarte. Los números '
          'irán teniendo más cifras a medida que avanzas.',
    ),
  ],
);

/// Preguntas diarias (§8) — la racha diaria (Anexo 5).
final ActivityTutorial dailyTutorial = ActivityTutorial(
  id: kTutDaily,
  title: 'Preguntas diarias',
  pages: [
    TutorialPage(
      icon: Icons.wb_sunny_outlined,
      title: 'Tres preguntas al día',
      body: 'Cada día te haremos 3 preguntas sencillas sobre tu día a día. '
          'Sirven para ejercitar tu memoria con calma.',
      example: (_) => const _DailyExample(),
    ),
    const TutorialPage(
      icon: Icons.edit_outlined,
      title: 'Responde a tu ritmo',
      body: 'Escribe tu respuesta y pulsa "Confirmar". Si no te acuerdas, '
          'pulsa "No me acuerdo": no pasa nada y no se considera un error.',
    ),
    const TutorialPage(
      icon: Icons.local_fire_department_outlined,
      title: 'Mantén tu racha',
      body: 'Entra cada día para sumar a tu racha. Lo importante no es '
          'acertar, sino recordar e intentarlo cada día.',
    ),
  ],
);

/// Todos los tutoriales indexados por id (útil para Ajustes → Cómo se juega).
final Map<String, ActivityTutorial> activityTutorials = {
  kTutMemory: memoryTutorial,
  kTutSentence: sentenceTutorial,
  kTutNumber: numberTutorial,
  kTutDaily: dailyTutorial,
};

// ---------------------------------------------------------------------------
// Ejemplos visuales (ligeros, solo ilustrativos; toques simples).
// ---------------------------------------------------------------------------

/// Mini-tablero de Memory: una pareja descubierta y dos cartas tapadas.
class _MemoryExample extends StatelessWidget {
  const _MemoryExample();

  @override
  Widget build(BuildContext context) {
    Widget tile({IconData? icon}) {
      final revealed = icon != null;
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: revealed
              ? AppColors.success.withValues(alpha: 0.12)
              : AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: revealed ? AppColors.success : AppColors.hairline,
            width: 2,
          ),
        ),
        child: Icon(
          icon ?? Icons.question_mark,
          size: 30,
          color: revealed ? AppColors.success : AppColors.primary,
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        tile(icon: Icons.star),
        tile(),
        tile(),
        tile(icon: Icons.star),
      ],
    );
  }
}

/// Mini-ejemplo de fichas de palabras (colocadas + disponibles).
class _SentenceExample extends StatelessWidget {
  const _SentenceExample();

  @override
  Widget build(BuildContext context) {
    Widget chip(String word, {required bool placed}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: placed ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.hairline, width: 2),
        ),
        child: Text(
          word,
          style: AppTextStyles.body.copyWith(
            color: placed ? AppColors.onPrimary : AppColors.textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            chip('Hoy', placed: true),
            chip('hace', placed: true),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            chip('sol', placed: false),
            chip('lluvia', placed: false),
            chip('frío', placed: false),
          ],
        ),
      ],
    );
  }
}

/// Mini-ejemplo de "Mayor o menor": consigna + dos números.
class _NumberExample extends StatelessWidget {
  const _NumberExample();

  @override
  Widget build(BuildContext context) {
    Widget numberBox(String n) {
      return Container(
        width: 84,
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimens.cardBorder,
          border: Border.all(color: AppColors.hairline, width: 2),
        ),
        child: Text(
          n,
          style: AppTextStyles.h1.copyWith(color: AppColors.primary),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Toca el MAYOR',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            numberBox('47'),
            const SizedBox(width: 18),
            numberBox('82'),
          ],
        ),
      ],
    );
  }
}

/// Mini-ejemplo de pregunta diaria: tarjeta con pregunta + campo simulado.
class _DailyExample extends StatelessWidget {
  const _DailyExample();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.cardBorder,
        border: Border.all(color: AppColors.hairline, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué comiste ayer?',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Text(
              'Escribe tu respuesta…',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMain.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}