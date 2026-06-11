import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/settings_provider.dart';
import 'theme/app_theme.dart';

/// Transiciones de navegación: FadeTransition de 200 ms, sin slides (§2.3).
class FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class GymBrainApp extends StatelessWidget {
  const GymBrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    final baseTheme = AppTheme.light;
    final theme = baseTheme.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadePageTransitionsBuilder(),
          TargetPlatform.iOS: FadePageTransitionsBuilder(),
        },
      ),
    );

    return MaterialApp(
      title: 'GymBrain',
      debugShowCheckedModeBanner: false,
      theme: theme,
      // Solo modo claro.
      themeMode: ThemeMode.light,
      // Aplica el factor de tamaño de texto globalmente (§3.2).
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(settings.textScaleFactor),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
