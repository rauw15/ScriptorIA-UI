import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/services/session_service.dart';
import '../../data/repositories/auth_repository_impl.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Verificar si hay usuario autenticado y navegar
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    try {
      final sessionService = SessionService();
      await sessionService.checkSessionTimeout();
      
      final authRepository = AuthRepositoryImpl();
      final user = await authRepository.getCurrentUser();
      
      if (mounted) {
        if (user != null) {
          await sessionService.resetSession();
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo con animación de pulso
                  _buildAnimatedLogo(),
                  const SizedBox(height: 30),
                  // Título
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimary,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtítulo
                  Text(
                    AppConstants.appSubtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Spinner de carga
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.onPrimary,
                      ),
                      strokeWidth: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.05),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.05, end: 1.0),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          onEnd: () {
            // Reiniciar animación
            if (mounted) {
              setState(() {});
            }
          },
          builder: (context, reverseScale, child) {
            return Transform.scale(
              scale: scale * reverseScale,
              child: _buildLogo(),
            );
          },
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: GeometricLogoPainter(),
      ),
    );
  }
}

class GeometricLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Crear forma geométrica abstracta (estrella/compás)
    final path = Path();
    
    // Dibujar una estrella de 4 puntas
    final points = 8;
    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * 3.14159) / points - 3.14159 / 2;
      final r = i % 2 == 0 ? radius : radius * 0.5;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Gradiente de rosa a verde
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primary.withOpacity(0.8),
        AppColors.secondary.withOpacity(0.8),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GeometricLogoPainter oldDelegate) => false;
  
  double cos(double angle) => math.cos(angle);
  double sin(double angle) => math.sin(angle);
}

