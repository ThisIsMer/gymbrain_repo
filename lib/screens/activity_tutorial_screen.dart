import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_tutorial.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';

/// Tutorial de 3 pantallas por actividad (Anexo 1/6).
///
/// Dos modos de uso:
///  - **Primera vez** ([reviewMode] = false): se muestra antes de jugar la
///    primera partida de la actividad. Al terminar (o saltar) marca el
///    tutorial como visto y devuelve `true` con `Navigator.pop(true)` para
///    que la pantalla anterior lance la actividad. Ofrece un enlace "Saltar".
///  - **Cómo se juega** ([reviewMode] = true): se abre desde la pausa de cada
///    juego o desde Ajustes. No marca nada; el botón final es "Entendido" y
///    arriba aparece "Cerrar".
class ActivityTutorialScreen extends StatefulWidget {
  final ActivityTutorial tutorial;
  final bool reviewMode;

  const ActivityTutorialScreen({
    super.key,
    required this.tutorial,
    this.reviewMode = false,
  });

  @override
  State<ActivityTutorialScreen> createState() => _ActivityTutorialScreenState();
}

class _ActivityTutorialScreenState extends State<ActivityTutorialScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  List<TutorialPage> get _pages => widget.tutorial.pages;
  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Cierra el tutorial. En primera vez marca como visto y devuelve `true`
  /// (para que Home/Inicio lance la actividad a continuación).
  Future<void> _finish() async {
    if (widget.reviewMode) {
      Navigator.of(context).pop();
      return;
    }
    await context.read<ProgressService>().markTutorialSeen(widget.tutorial.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: AppDimens.navTransition,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastLabel = widget.reviewMode ? 'Entendido' : 'Empezar';
    final lastIcon = widget.reviewMode ? Icons.check : Icons.play_arrow;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH,
            vertical: AppDimens.screenPaddingV,
          ),
          child: Column(
            children: [
              // Cabecera: título de la actividad + acción "Cerrar"/"Saltar".
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.tutorial.title,
                      style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _finish,
                    icon: Icon(
                      widget.reviewMode ? Icons.close : Icons.skip_next_outlined,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      widget.reviewMode ? 'Cerrar' : 'Saltar',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _TutorialPageView(page: _pages[i]),
                ),
              ),
              const SizedBox(height: 16),
              _Dots(count: _pages.length, index: _index),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _isLast ? lastLabel : 'Siguiente',
                icon: _isLast ? lastIcon : Icons.arrow_forward,
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialPageView extends StatelessWidget {
  final TutorialPage page;
  const _TutorialPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView para no desbordar con tamaños de texto grandes.
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Ejemplo visual si existe; si no, icono grande de identidad.
          Center(
            child: page.example != null
                ? page.example!(context)
                : Icon(page.icon, size: 110, color: AppColors.secondary),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: AppTextStyles.h1.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(page.body, style: AppTextStyles.body),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Indicador de páginas (idéntico al del onboarding, reutilizado aquí).
class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: active ? 22 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.hairline,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}