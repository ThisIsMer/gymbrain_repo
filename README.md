# GymBrain

Prototipo de **estimulación cognitiva** para personas mayores de 65 años.
Aplicación **preventiva, gratuita y no diagnóstica**. Todos los datos se
guardan **solo en el dispositivo** (sin servidores, sin cuentas). Solo modo
claro.

> Esta aplicación no es una prueba diagnóstica. Si tienes dudas sobre tu
> memoria, consulta a tu médico.

## Tecnología
- Flutter (null-safety), Dart 3
- `provider` (gestión de estado con `ChangeNotifier`)
- `shared_preferences` (persistencia local en JSON)
- `google_fonts` (tipografía Nunito)

## Estructura
```
lib/
  theme/        Tokens de diseño (colores, tipografías, dimensiones, tema)
  models/       Modelos de datos y de sesión
  data/         Bancos de contenido (memory, frases, preguntas, consejos)
  services/     Almacenamiento, ajustes y lógica de progreso/racha
  widgets/      Componentes reutilizables (botón, tarjeta, overlay de pausa…)
  screens/      Pantallas (splash, onboarding, home, 3 demos, stats, ajustes)
  app.dart      MaterialApp + tema + escala de texto global
  main.dart     Punto de entrada (MultiProvider)
assets/images/  PNG opcionales de las cartas de Memory (la app funciona sin ellos)
```

## Cómo ejecutar
```bash
flutter pub get
flutter run
```

## Imágenes del juego Memory (opcionales)
Las cartas buscan `assets/images/<id>.png` (p. ej. `paella.png`,
`gazpacho.png`). **Si el PNG no existe, la carta muestra el nombre en texto**,
por lo que la app compila y funciona con la carpeta vacía.
