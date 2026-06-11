import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class _OnbPage {
  final IconData icon;
  final String title;
  final String body;
  final bool showDisclaimer;
  const _OnbPage(this.icon, this.title, this.body,
      {this.showDisclaimer = false});
}

const List<_OnbPage> _pages = [
  _OnbPage(
    Icons.psychology_outlined,
    'Bienvenido a GymBrain',
    'Pequeños ejercicios diarios para mantener tu memoria y tu atención en forma.',
    showDisclaimer: true,
  ),
  _OnbPage(
    Icons.local_fire_department_outlined,
    'Preguntas diarias',
    'Cada día te haremos 3 preguntas sencillas sobre tu día. ¡Entra a diario para mantener tu racha!',
  ),
  _OnbPage(
    Icons.extension_outlined,
    'Las actividades',
    'Tres juegos breves: encontrar parejas, reconstruir frases y comparar números.',
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
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _pages.length - 1;

  Future<void> _finish() async {
    if (widget.reviewMode) {
      Navigator.of(context).pop();
      return;
    }
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
              if (widget.reviewMode)
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.primary),
                    label: Text('Cerrar',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.primary)),
                  ),
                ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _PageView(page: _pages[i]),
                ),
              ),
              const SizedBox(height: 16),
              _Dots(count: _pages.length, index: _index),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Icon(page.icon, size: 110, color: AppColors.secondary),
        ),
        const SizedBox(height: 32),
        Text(page.title, style: AppTextStyles.h1.copyWith(color: AppColors.primary)),
        const SizedBox(height: 16),
        Text(page.body, style: AppTextStyles.body),
        if (page.showDisclaimer) ...[
          const SizedBox(height: 24),
          const DisclaimerBanner(),
        ],
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
