import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Una barra del gráfico.
class BarDatum {
  final double value;
  final String label; // etiqueta bajo la barra (p.ej. valor o índice)
  const BarDatum(this.value, this.label);
}

/// Mini-gráfica de barras nativa (Anexo 8 §4.2), construida con
/// Container + FractionallySizedBox; sin librerías de charting.
///
/// - [slots]: número fijo de huecos mostrados (Anexo 8 §4.2: 7 sesiones). Si
///   hay menos sesiones que huecos, los huecos más antiguos (a la izquierda)
///   se dibujan como barras vacías (contorno sin relleno) para distinguir
///   "no se jugó" de "se jugó con un resultado bajo".
/// - [fixedMax]: escala vertical fija. Se usa en métricas en porcentaje
///   (eje 0–100). Si es null, la escala se ajusta al valor mayor de la ventana
///   (métricas de tiempo, sin máximo natural).
class BarChartSimple extends StatelessWidget {
  final String? title;
  final List<BarDatum> data; // ya recortado a <= slots por el llamante
  final String? subtitle;
  final String emptyMessage;
  final int slots;
  final double? fixedMax;

  const BarChartSimple({
    super.key,
    this.title,
    required this.data,
    this.subtitle,
    this.emptyMessage = 'Todavía no has jugado a esta actividad.',
    this.slots = 7,
    this.fixedMax,
  });

  /// Descripción textual del gráfico para lectores de pantalla, que resume
  /// los valores mostrados sin depender de la lectura visual de las barras.
  String _semanticLabel() {
    final parts = <String>[];
    if (title != null) parts.add(title!);
    if (subtitle != null) parts.add(subtitle!);
    if (data.isEmpty) {
      parts.add(emptyMessage);
    } else {
      final values = data
          .map((d) => '${d.label}: ${d.value.round()}')
          .join(', ');
      parts.add('Valores de menos reciente a más reciente: $values');
    }
    return parts.join('. ');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _semanticLabel(),
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.h2),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: AppTextStyles.caption),
            ],
            const SizedBox(height: 12),
          ],
          if (data.isEmpty)
            Text(emptyMessage, style: AppTextStyles.body)
          else
            ExcludeSemantics(child: _buildBars()),
        ],
      ),
    );
  }

  Widget _buildBars() {
    // Escala: fija (métricas en %) o ajustada al máximo de la ventana.
    final maxValue =
        data.map((d) => d.value).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = fixedMax ?? (maxValue <= 0 ? 1.0 : maxValue);

    // Huecos sin datos (más antiguos), a la izquierda.
    final emptyCount = (slots - data.length).clamp(0, slots);

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < emptyCount; i++)
            Expanded(child: _emptySlot()),
          for (int i = 0; i < data.length; i++)
            Expanded(child: _bar(data[i], safeMax)),
        ],
      ),
    );
  }

  /// Barra con datos: valor numérico encima + barra rellena.
  Widget _bar(BarDatum d, double safeMax) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(d.value.round().toString(), style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: (d.value / safeMax).clamp(0.04, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            d.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  /// Hueco sin datos: marco del color principal a baja opacidad, sin relleno.
  Widget _emptySlot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Espacio reservado para alinear con las barras que sí muestran valor.
          Text(' ', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(' ', textAlign: TextAlign.center, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}