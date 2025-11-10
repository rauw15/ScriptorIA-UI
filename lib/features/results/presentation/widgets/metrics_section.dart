import 'package:flutter/material.dart';
import '../../domain/entities/analysis_result.dart';

class MetricsSection extends StatelessWidget {
  final AnalysisResult result;

  const MetricsSection({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Análisis Detallado',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF22191b),
          ),
        ),
        const SizedBox(height: 15),
        MetricItem(
          name: 'Proporción',
          value: result.proportion,
          color: const Color(0xFF1c6b50),
        ),
        const SizedBox(height: 20),
        MetricItem(
          name: 'Inclinación',
          value: result.inclination,
          color: const Color(0xFF8d4a5b),
        ),
        const SizedBox(height: 20),
        MetricItem(
          name: 'Espaciado',
          value: result.spacing,
          color: const Color(0xFF7b5733),
        ),
        const SizedBox(height: 20),
        MetricItem(
          name: 'Consistencia',
          value: result.consistency,
          color: const Color(0xFF1c6b50),
        ),
      ],
    );
  }
}

class MetricItem extends StatelessWidget {
  final String name;
  final double value;
  final Color color;

  const MetricItem({
    super.key,
    required this.name,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF22191b),
              ),
            ),
            Text(
              '${value.toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 10,
            backgroundColor: const Color(0xFFfbeaec),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

