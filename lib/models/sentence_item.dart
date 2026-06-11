/// Frase del banco de la Demo 2 (§11.2).
///
/// - [texto]: la frase completa tal cual.
/// - [palabras]: derivadas de [texto] por split de espacios (mayúsculas y
///   signos conservados, para comparación de orden exacta).
/// - [trampas]: distractores que se añaden a la cuadrícula.
/// - [intercambiables]: pares de palabras que YA están en la frase y que se
///   presentan ambas en la cuadrícula (el reto es el orden exacto); cada par
///   se expresa como "a↔b".
class SentenceItem {
  final String texto;
  final List<String> trampas;
  final List<String> intercambiables;
  final int nivel; // 1..4

  SentenceItem({
    required this.texto,
    required this.trampas,
    this.intercambiables = const [],
    required this.nivel,
  });

  /// Palabras de la frase en orden, divididas por espacios.
  List<String> get palabras =>
      texto.split(' ').where((w) => w.trim().isNotEmpty).toList();

  /// Identificador estable de la frase (para el set de "ya vistas").
  String get id => '$nivel::$texto';

  /// Construye la cuadrícula de opciones: palabras de la frase + trampas
  /// + las palabras "extra" de pares intercambiables que no estén ya en la
  /// frase. (En los pares intercambiables ambas palabras ya están presentes
  /// en el texto en este banco, así que normalmente no añaden nada nuevo.)
  List<String> buildOptions() {
    final options = <String>[...palabras, ...trampas];
    for (final pair in intercambiables) {
      final parts = pair.split('↔');
      for (final p in parts) {
        final w = p.trim();
        if (w.isNotEmpty && !options.contains(w)) {
          options.add(w);
        }
      }
    }
    return options;
  }
}
