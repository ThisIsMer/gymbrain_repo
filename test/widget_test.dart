import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gymbrain/app.dart';
import 'package:gymbrain/services/progress_service.dart';
import 'package:gymbrain/services/settings_provider.dart';
import 'package:gymbrain/services/storage_service.dart';

void main() {
  testWidgets('La app arranca y muestra el splash', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final storage = await StorageService.create();
    final progress = ProgressService(storage);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storage),
          Provider<ProgressService>.value(value: progress),
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider(storage),
          ),
        ],
        child: const GymBrainApp(),
      ),
    );

    // En el primer frame debe verse el nombre de la app en el splash.
    expect(find.text('GymBrain'), findsOneWidget);

    // Deja pasar el temporizador del splash (1,6 s) y estabiliza la navegación.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}