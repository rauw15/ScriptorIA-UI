import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DrawingCanvas extends StatefulWidget {
  final Function(String imagePath) onDrawingComplete;
  final VoidCallback onClear;

  const DrawingCanvas({
    super.key,
    required this.onDrawingComplete,
    required this.onClear,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<DrawingPoint> _points = [];
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFd6c2c5),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            // Canvas de dibujo
            GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: SizedBox(
                width: double.infinity,
                height: 300,
                child: CustomPaint(
                  painter: DrawingPainter(_points),
                  size: const Size(double.infinity, 300),
                ),
              ),
            ),
            // Botones de control
            Positioned(
              bottom: 10,
              right: 10,
              child: Row(
                children: [
                  // Botón limpiar
                  Material(
                    color: const Color(0xFFba1a1a),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _clearCanvas,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón guardar
                  Material(
                    color: const Color(0xFF1c6b50),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _saveDrawing,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _points.add(DrawingPoint(
        point: details.localPosition,
        paint: Paint()
          ..color = const Color(0xFF22191b)
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDrawing) {
      setState(() {
        _points.add(DrawingPoint(
          point: details.localPosition,
          paint: Paint()
            ..color = const Color(0xFF22191b)
            ..strokeWidth = 4.0
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        ));
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDrawing = false;
    });
  }

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
    widget.onClear();
  }

  Future<void> _saveDrawing() async {
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dibuja algo antes de guardar'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Obtener el tamaño del canvas
      final size = MediaQuery.of(context).size;
      final canvasWidth = (size.width - 40).clamp(300.0, 600.0);
      final canvasHeight = 300.0;
      final canvasSize = Size(canvasWidth, canvasHeight);

      // Crear un recorder para capturar el dibujo
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Dibujar el fondo blanco
      final backgroundPaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
        backgroundPaint,
      );

      // Dibujar todos los puntos
      final painter = DrawingPainter(_points);
      painter.paint(canvas, canvasSize);

      // Convertir a imagen
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        canvasSize.width.toInt(),
        canvasSize.height.toInt(),
      );

      // Convertir a bytes
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('No se pudo convertir el dibujo a imagen');
      }
      final bytes = byteData.buffer.asUint8List();

      // Guardar archivo
      final directory = await getTemporaryDirectory();
      final fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Notificar que el dibujo está completo
      widget.onDrawingComplete(filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dibujo guardado correctamente'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el dibujo: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class DrawingPoint {
  final Offset point;
  final Paint paint;

  DrawingPoint({
    required this.point,
    required this.paint,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(
        points[i].point,
        points[i + 1].point,
        points[i].paint,
      );
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

