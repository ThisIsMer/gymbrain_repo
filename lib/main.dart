import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/progress_service.dart';
import 'services/settings_provider.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga inicial de servicios (almacenamiento local).
  final storage = await StorageService.create();
  final progress = ProgressService(storage);

  runApp(
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
}
