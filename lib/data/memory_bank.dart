import '../models/memory_item.dart';

/// Banco de 50 elementos para la Demo 1 (§11.1). 5 categorías × 10.
/// `id` = nombre del asset (assets/images/<id>.png). `nombre` = legible.
const List<MemoryItem> memoryBank = [
  // comidas
  MemoryItem(id: 'paella', nombre: 'Paella', categoria: 'comidas'),
  MemoryItem(id: 'gazpacho', nombre: 'Gazpacho', categoria: 'comidas'),
  MemoryItem(
      id: 'tortilla_patata',
      nombre: 'Tortilla de patata',
      categoria: 'comidas'),
  MemoryItem(
      id: 'churros_chocolate',
      nombre: 'Chocolate con churros',
      categoria: 'comidas'),
  MemoryItem(id: 'torrijas', nombre: 'Torrijas', categoria: 'comidas'),
  MemoryItem(id: 'croquetas', nombre: 'Croquetas', categoria: 'comidas'),
  MemoryItem(id: 'lentejas', nombre: 'Lentejas', categoria: 'comidas'),
  MemoryItem(
      id: 'patatas_bravas', nombre: 'Patatas bravas', categoria: 'comidas'),
  MemoryItem(
      id: 'pulpo_gallega', nombre: 'Pulpo a la gallega', categoria: 'comidas'),
  MemoryItem(
      id: 'jamon_iberico', nombre: 'Jamón ibérico', categoria: 'comidas'),

  // animales
  MemoryItem(id: 'gato', nombre: 'Gato', categoria: 'animales'),
  MemoryItem(id: 'perro', nombre: 'Perro', categoria: 'animales'),
  MemoryItem(id: 'conejo', nombre: 'Conejo', categoria: 'animales'),
  MemoryItem(id: 'pez', nombre: 'Pez', categoria: 'animales'),
  MemoryItem(id: 'pato', nombre: 'Pato', categoria: 'animales'),
  MemoryItem(id: 'tortuga', nombre: 'Tortuga', categoria: 'animales'),
  MemoryItem(id: 'loro', nombre: 'Loro', categoria: 'animales'),
  MemoryItem(id: 'cerdo', nombre: 'Cerdo', categoria: 'animales'),
  MemoryItem(id: 'vaca', nombre: 'Vaca', categoria: 'animales'),
  MemoryItem(id: 'caballo', nombre: 'Caballo', categoria: 'animales'),

  // artistas
  MemoryItem(
      id: 'raffaella_carra', nombre: 'Raffaella Carrà', categoria: 'artistas'),
  MemoryItem(
      id: 'concha_velasco', nombre: 'Concha Velasco', categoria: 'artistas'),
  MemoryItem(
      id: 'julio_iglesias', nombre: 'Julio Iglesias', categoria: 'artistas'),
  MemoryItem(id: 'nino_bravo', nombre: 'Nino Bravo', categoria: 'artistas'),
  MemoryItem(id: 'raphael', nombre: 'Raphael', categoria: 'artistas'),
  MemoryItem(id: 'camilo_sesto', nombre: 'Camilo Sesto', categoria: 'artistas'),
  MemoryItem(id: 'rocio_jurado', nombre: 'Rocío Jurado', categoria: 'artistas'),
  MemoryItem(id: 'celia_cruz', nombre: 'Celia Cruz', categoria: 'artistas'),
  MemoryItem(
      id: 'manolo_escobar', nombre: 'Manolo Escobar', categoria: 'artistas'),
  MemoryItem(id: 'lola_flores', nombre: 'Lola Flores', categoria: 'artistas'),

  // flores
  MemoryItem(id: 'rosa', nombre: 'Rosa', categoria: 'flores'),
  MemoryItem(id: 'clavel', nombre: 'Clavel', categoria: 'flores'),
  MemoryItem(id: 'margarita', nombre: 'Margarita', categoria: 'flores'),
  MemoryItem(id: 'tulipan', nombre: 'Tulipán', categoria: 'flores'),
  MemoryItem(id: 'girasol', nombre: 'Girasol', categoria: 'flores'),
  MemoryItem(id: 'violeta', nombre: 'Violeta', categoria: 'flores'),
  MemoryItem(id: 'orquidea', nombre: 'Orquídea', categoria: 'flores'),
  MemoryItem(id: 'amapola', nombre: 'Amapola', categoria: 'flores'),
  MemoryItem(id: 'azucena', nombre: 'Azucena', categoria: 'flores'),
  MemoryItem(id: 'mimosa', nombre: 'Mimosa', categoria: 'flores'),

  // ciudades
  MemoryItem(id: 'madrid', nombre: 'Madrid', categoria: 'ciudades'),
  MemoryItem(id: 'barcelona', nombre: 'Barcelona', categoria: 'ciudades'),
  MemoryItem(id: 'sevilla', nombre: 'Sevilla', categoria: 'ciudades'),
  MemoryItem(id: 'valencia', nombre: 'Valencia', categoria: 'ciudades'),
  MemoryItem(id: 'bilbao', nombre: 'Bilbao', categoria: 'ciudades'),
  MemoryItem(id: 'granada', nombre: 'Granada', categoria: 'ciudades'),
  MemoryItem(id: 'zamora', nombre: 'Zamora', categoria: 'ciudades'),
  MemoryItem(id: 'salamanca', nombre: 'Salamanca', categoria: 'ciudades'),
  MemoryItem(id: 'toledo', nombre: 'Toledo', categoria: 'ciudades'),
  MemoryItem(id: 'malaga', nombre: 'Málaga', categoria: 'ciudades'),
];
