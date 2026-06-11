import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/disclaimer_banner.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// Splash (§4.1). Fondo primary, nombre centrado, disclaimer.
/// Duración máx. 2 s; enruta según onboarding_done.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Tiempo mínimo de marca; la carga real de servicios ya ocurrió en main.
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final progress = context.read<ProgressService>();
    final done = progress.onboardingDone;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => done ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                'assets/branding/splash_logo.png',
                width: 160,
                fit: BoxFit.contain, // muestra la imagen entera, no la recorta
              ),
              const SizedBox(height: 16),
              Text(
                'GymBrain',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.onPrimary,
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
              ),
              const Spacer(),
              const DisclaimerBanner(color: AppColors.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
