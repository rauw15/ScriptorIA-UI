import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/practice_item.dart';

class LetterCard extends StatelessWidget {
  final PracticeItem practiceItem;
  final VoidCallback? onTap;

  const LetterCard({
    super.key,
    required this.practiceItem,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Widget? statusIcon;

    // Solo se muestra en verde si está completada exitosamente (score >= 70)
    if (practiceItem.isCompletedSuccessfully) {
      backgroundColor = AppColors.secondaryContainer;
      borderColor = AppColors.secondary;
      textColor = AppColors.onSecondaryContainer;
      statusIcon = const Positioned(
        top: 4,
        right: 4,
        child: Icon(
          Icons.check_circle,
          size: 20,
          color: AppColors.secondary,
        ),
      );
    } else if (practiceItem.isInProgress) {
      // En progreso: fondo rosa (intentada pero no completada exitosamente)
      backgroundColor = AppColors.primaryContainer;
      borderColor = AppColors.primary;
      textColor = AppColors.onPrimaryContainer;
    } else {
      // Pendiente: fondo gris claro
      backgroundColor = AppColors.surfaceContainerLow;
      borderColor = AppColors.outlineVariant;
      textColor = AppColors.onSurface;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                practiceItem.text,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            if (statusIcon != null) statusIcon,
            // Mostrar score si está disponible (incluso si no está completada exitosamente)
            if (practiceItem.score != null && !practiceItem.isCompletedSuccessfully)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${practiceItem.score!.toInt()}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

