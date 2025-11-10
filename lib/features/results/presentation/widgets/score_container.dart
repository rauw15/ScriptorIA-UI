import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScoreContainer extends StatelessWidget {
  final int score;

  const ScoreContainer({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFfff0f2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFd6c2c5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Puntuación circular
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: CircularScorePainter(score: score),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1c6b50),
                      ),
                    ),
                    const Text(
                      '/ 100',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF514346),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Título y mensaje
          Text(
            _getScoreTitle(score),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF22191b),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu caligrafía está mejorando',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF514346),
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreTitle(int score) {
    if (score >= 90) return '¡Excelente Trabajo!';
    if (score >= 75) return '¡Muy Bien!';
    if (score >= 60) return '¡Buen Trabajo!';
    return 'Sigue Practicando';
  }
}

class CircularScorePainter extends CustomPainter {
  final int score;

  CircularScorePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Círculo de fondo
    final backgroundPaint = Paint()
      ..color = const Color(0xFFf5e4e6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Círculo de progreso
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1c6b50), Color(0xFF8d4a5b)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Empieza desde arriba
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularScorePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}

