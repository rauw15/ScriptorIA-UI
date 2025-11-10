import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile_data.dart';

class AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsGrid({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementCard(achievement: achievement);
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final backgroundColor = isUnlocked 
        ? AppColors.secondaryContainer 
        : AppColors.primaryContainer;
    final iconColor = isUnlocked 
        ? AppColors.onSecondaryContainer 
        : AppColors.onPrimaryContainer;
    final textColor = isUnlocked 
        ? AppColors.onSecondaryContainer 
        : AppColors.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono
          Icon(
            _getIcon(achievement.icon),
            size: 40,
            color: iconColor,
          ),
          const SizedBox(height: 8),
          
          // Título
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'trophy':
        return Icons.emoji_events;
      case 'target':
        return Icons.track_changes;
      case 'star':
        return Icons.star;
      case 'lock':
        return Icons.lock;
      default:
        return Icons.star;
    }
  }
}

