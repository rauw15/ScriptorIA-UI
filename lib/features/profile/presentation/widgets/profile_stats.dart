import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/user_stats.dart';

class ProfileStats extends StatelessWidget {
  final UserStats stats;

  const ProfileStats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: _calculateActiveDays(stats).toString(),
            label: 'Días activos',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: stats.completedPractices.toString(),
            label: 'Prácticas',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: stats.totalAchievements.toString(),
            label: 'Logros',
          ),
        ),
      ],
    );
  }

  int _calculateActiveDays(UserStats stats) {
    // Simular días activos basado en prácticas completadas
    // En producción esto vendría del backend
    return (stats.completedPractices / 2).round().clamp(1, 365);
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

