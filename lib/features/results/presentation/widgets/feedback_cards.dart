import 'package:flutter/material.dart';

class FeedbackCards extends StatelessWidget {
  final String strengths;
  final String improvements;

  const FeedbackCards({
    super.key,
    required this.strengths,
    required this.improvements,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FeedbackCard(
          icon: Icons.check_circle,
          title: 'Fortalezas',
          message: strengths,
          isSuccess: true,
        ),
        const SizedBox(height: 12),
        FeedbackCard(
          icon: Icons.lightbulb_outline,
          title: 'A Mejorar',
          message: improvements,
          isSuccess: false,
        ),
      ],
    );
  }
}

class FeedbackCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool isSuccess;

  const FeedbackCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isSuccess
            ? const Color(0xFFa7f2d0) // secondaryContainer
            : const Color(0xFFffdcbe), // tertiaryContainer
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSuccess
              ? const Color(0xFF1c6b50) // secondary
              : const Color(0xFF7b5733), // tertiary
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 32,
            color: isSuccess
                ? const Color(0xFF00513a) // onSecondaryContainer
                : const Color(0xFF60401e), // onTertiaryContainer
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSuccess
                        ? const Color(0xFF00513a)
                        : const Color(0xFF60401e),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSuccess
                        ? const Color(0xFF00513a)
                        : const Color(0xFF60401e),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

