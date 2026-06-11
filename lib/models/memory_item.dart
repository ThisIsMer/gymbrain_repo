/// Elemento del banco de Memory (§11.1).
/// `id` se usa como nombre de asset: assets/images/<id>.png
class MemoryItem {
  final String id;
  final String nombre; // nombre legible (fallback de texto)
  final String categoria;

  const MemoryItem({
    required this.id,
    required this.nombre,
    required this.categoria,
  });
}
