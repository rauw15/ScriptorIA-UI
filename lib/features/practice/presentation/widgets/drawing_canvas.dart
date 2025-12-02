import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

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
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveDrawing() async {
    try {
      final Uint8List? imageBytes = await _controller.toPngBytes();
      if (imageBytes == null || imageBytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor dibuja algo antes de guardar'),
            backgroundColor: Color(0xFFba1a1a),
          ),
        );
        return;
      }

      // Guardar la imagen en un archivo temporal
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      widget.onDrawingComplete(imagePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el dibujo: $e'),
          backgroundColor: const Color(0xFFba1a1a),
        ),
      );
    }
  }

  void _clearCanvas() {
    _controller.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFF1c6b50),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.white,
              height: 300,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearCanvas,
                icon: const Icon(Icons.clear, size: 20),
                label: const Text('Limpiar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveDrawing,
                icon: const Icon(Icons.check, size: 20),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1c6b50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

