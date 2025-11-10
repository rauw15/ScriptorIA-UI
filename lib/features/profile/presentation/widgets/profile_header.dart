import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile_data.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileData profileData;

  const ProfileHeader({
    super.key,
    required this.profileData,
  });

  @override
  Widget build(BuildContext context) {
    final userName = profileData.user.name ?? 
                     profileData.user.email.split('@')[0];
    final userInitial = userName.isNotEmpty 
                        ? userName[0].toUpperCase() 
                        : 'U';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary,
            ),
            child: Center(
              child: Text(
                userInitial,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Nombre
          Text(
            userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          
          // Email
          Text(
            profileData.user.email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          
          // Badge de nivel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4), // Amarillo claro
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wb_sunny,
                  color: Color(0xFFF57F17),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  _getUserLevel(profileData.stats),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUserLevel(stats) {
    final progress = stats.progressPercentageRounded;
    if (progress >= 90) return 'Experto';
    if (progress >= 70) return 'Estudiante Avanzada';
    if (progress >= 50) return 'Estudiante Intermedia';
    return 'Estudiante Principiante';
  }
}

