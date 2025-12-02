import 'package:flutter/material.dart';

class TipsCard extends StatelessWidget {
  const TipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFffdcbe),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFd6c2c5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFF60401e)),
              SizedBox(width: 8),
              Text(
                'Consejos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF60401e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip('Usa buena iluminación'),
          _buildTip('Escribe en papel blanco'),
          _buildTip('Mantén la cámara estable'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7b5733),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF60401e),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

