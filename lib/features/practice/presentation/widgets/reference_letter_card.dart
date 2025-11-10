import 'package:flutter/material.dart';

class ReferenceLetterCard extends StatelessWidget {
  final String letter;

  const ReferenceLetterCard({
    super.key,
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFffd9e0),
            Color(0xFFfff0f2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFd6c2c5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Letra de Referencia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF713344),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8d4a5b),
                fontFamily: 'Georgia',
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Traza la letra con cuidado y precisión',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF713344),
            ),
          ),
        ],
      ),
    );
  }
}

