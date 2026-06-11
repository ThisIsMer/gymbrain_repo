import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../services/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class _OnbPage {
  final String kicker;
  final String title;
  final String body;
  final String tag;
  final List<Widget> Function() previews;
  final bool showDisclaimer;

  const _OnbPage({
    required this.kicker,
    required this.title,
    required this.body,
    required this.tag,
    required this.previews,
    this.showDisclaimer = false,
  });
}

List<Widget> _welcomePreviews() => [
      const _PreviewTile(child: Icon(Icons.psychology_outlined, color: AppColors.primary, size: 32)),
    ];

List<Widget> _streakPreviews() => [
      for (int i = 1; i <= 5; i++)
        _StreakPill(label: '$i', active: i <= 3),
    ];

List<Widget> _activitiesPreviews() => [
      const _PreviewTile(child: Icon(Icons.grid_view_outlined, color: AppColors.primary, size: 28)),
      _PreviewTile(child: Text('AB', style: AppTextStyles.h2.copyWith(color: AppColors.primary))),
      _PreviewTile(child: Text('13', style: AppTextStyles.h2.copyWith(color: AppColors.primary))),
    ];

final List<_OnbPage> _pages = [
  const _OnbPage(
    kicker: 'BIENVENIDA',
    title: 'Bienvenido a GymBrain',
    body: 'Pequeños ejercicios diarios para mantener tu memoria y tu '
        'atención en forma.',
    tag: 'welcome',
    previews: _welcomePreviews,
    showDisclaimer: true,
  ),
  const _OnbPage(
    kicker: 'RACHA DIARIA',
    title: 'Tres preguntas al día',
    body: 'Cada mañana te haremos 3 preguntas sencillas. Mantén tu racha y '
        'verás tu progreso semana a semana.',
    tag: 'streak',
    previews: _streakPreviews,
  ),
  const _OnbPage(
    kicker: 'ACTIVIDADES',
    title: 'Mini-juegos para entrenar',
    body: 'Memoria visual, palabras y cálculo: tres demos cortas para '
        'ejercitar distintas habilidades.',
    tag: 'activities',
    previews: _activitiesPreviews,
  ),
];

/// Onboarding (§4.2). 3 pantallas. En [reviewMode] no marca onboarding_done
/// y muestra "Cerrar" (reaccesible desde Ajustes → Cómo se juega).
class OnboardingScreen extends StatefulWidget {
  final bool reviewMode;
  const OnboardingScreen({super.key, this.reviewMode = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _index = 0;

  // Nº total de páginas: las informativas + la de nombre (solo si no es revisión).
  int get _pageCount => _pages.length + (widget.reviewMode ? 0 : 1);

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _pageCount - 1;

  Future<void> _finish() async {
    if (widget.reviewMode) {
      Navigator.of(context).pop();
      return;
    }
    await context
        .read<SettingsProvider>()
        .setUserName(_nameController.text.trim());
    if (!mounted) return;
    await context.read<ProgressService>().setOnboardingDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
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
              Align(
                alignment: Alignment.topRight,
                child: widget.reviewMode
                    ? TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppColors.primary),
                        label: Text('Cerrar',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.primary)),
                      )
                    : TextButton(
                        onPressed: _finish,
                        child: Text('Saltar',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textMain.withValues(alpha: 0.5),
                            )),
                      ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pageCount,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => i < _pages.length
                      ? _PageView(page: _pages[i])
                      : _NamePage(controller: _nameController),
                ),
              ),
              const SizedBox(height: 16),
              _Dots(count: _pageCount, index: _index),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _isLast ? 'Empezar' : 'Siguiente',
                icon: _isLast ? Icons.check : Icons.arrow_forward,
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  final _OnbPage page;
  const _PageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _IllustrationBox(previews: page.previews(), tag: page.tag),
          const SizedBox(height: 28),
          Text(
            page.kicker,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(page.title, style: AppTextStyles.h1),
          const SizedBox(height: 16),
          Text(page.body, style: AppTextStyles.body),
          if (page.showDisclaimer) ...[
            const SizedBox(height: 24),
            const DisclaimerBanner(),
          ],
        ],
      ),
    );
  }
}

/// Caja de ilustración (placeholder): previsualizaciones centradas + etiqueta.
class _IllustrationBox extends StatelessWidget {
  final List<Widget> previews;
  final String tag;
  const _IllustrationBox({required this.previews, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Stack(
        children: [
          Center(
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: previews,
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Text(
              'ilustración · $tag',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMain.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta cuadrada blanca con borde, usada en las previsualizaciones.
class _PreviewTile extends StatelessWidget {
  final Widget child;
  const _PreviewTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: child,
    );
  }
}

/// Píldora numerada de la racha (activa = naranja, inactiva = contorno).
class _StreakPill extends StatelessWidget {
  final String label;
  final bool active;
  const _StreakPill({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.secondary : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: active ? null : Border.all(color: AppColors.hairline, width: 2),
      ),
      child: Text(
        label,
        style: AppTextStyles.h2.copyWith(
          color: active ? AppColors.onPrimary : AppColors.textMain.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  const _NamePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Icon(Icons.waving_hand_outlined,
              size: 110, color: AppColors.secondary),
        ),
        const SizedBox(height: 32),
        Text('¿Cómo te llamas?',
            style: AppTextStyles.h1.copyWith(color: AppColors.primary)),
        const SizedBox(height: 16),
        Text('Usaremos tu nombre para saludarte cada día.',
            style: AppTextStyles.body),
        const SizedBox(height: 24),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Tu nombre (opcional)',
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

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
