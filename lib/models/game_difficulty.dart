/// Dificultad de la Demo 1 (Memory) y configuración del tablero (§5.1).
enum GameDifficulty { facil, normal, dificil }

extension GameDifficultyX on GameDifficulty {
  /// Etiqueta visible en español.
  String get label {
    switch (this) {
      case GameDifficulty.facil:
        return 'Fácil';
      case GameDifficulty.normal:
        return 'Normal';
      case GameDifficulty.dificil:
        return 'Difícil';
    }
  }

  /// Identificador persistido en `MemorySession.difficulty`.
  String get key {
    switch (this) {
      case GameDifficulty.facil:
        return 'facil';
      case GameDifficulty.normal:
        return 'normal';
      case GameDifficulty.dificil:
        return 'dificil';
    }
  }

  /// Columnas del tablero.
  int get columns {
    switch (this) {
      case GameDifficulty.facil:
        return 4; // 4x2
      case GameDifficulty.normal:
        return 4; // 4x4
      case GameDifficulty.dificil:
        return 4; // 6x4 -> 4 columnas, 6 filas
    }
  }

  /// Filas del tablero.
  int get rows {
    switch (this) {
      case GameDifficulty.facil:
        return 2;
      case GameDifficulty.normal:
        return 4;
      case GameDifficulty.dificil:
        return 6;
    }
  }

  /// Número de parejas.
  int get pairs {
    switch (this) {
      case GameDifficulty.facil:
        return 4; // 8 cartas
      case GameDifficulty.normal:
        return 8; // 16 cartas
      case GameDifficulty.dificil:
        return 12; // 24 cartas
    }
  }

  int get totalCards => pairs * 2;

  static GameDifficulty fromKey(String key) {
    switch (key) {
      case 'facil':
        return GameDifficulty.facil;
      case 'dificil':
        return GameDifficulty.dificil;
      case 'normal':
      default:
        return GameDifficulty.normal;
    }
  }
}
