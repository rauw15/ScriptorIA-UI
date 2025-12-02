import 'dart:io';
import 'package:flutter/material.dart';
import 'drawing_canvas.dart';

enum CaptureMode { photo, gallery, canvas }

class CaptureSection extends StatefulWidget {
  final String? imagePath;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickFromGallery;
  final VoidCallback onRemoveImage;
  final Function(String) onCanvasComplete;

  const CaptureSection({
    super.key,
    this.imagePath,
    required this.onTakePhoto,
    required this.onPickFromGallery,
    required this.onRemoveImage,
    required this.onCanvasComplete,
  });

  @override
  State<CaptureSection> createState() => _CaptureSectionState();
}

class _CaptureSectionState extends State<CaptureSection> {
  CaptureMode _currentMode = CaptureMode.photo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu Trazo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF22191b),
          ),
        ),
        const SizedBox(height: 15),
        
        // Selector de modo
        _buildModeSelector(),
        
        const SizedBox(height: 15),
        
        // Área de captura o imagen según el modo
        _buildCaptureArea(context),
        
        const SizedBox(height: 15),
        
        // Botones de acción (solo si no es canvas)
        if (_currentMode != CaptureMode.canvas) _buildActionButtons(),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFfbeaec),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              mode: CaptureMode.photo,
              icon: Icons.camera_alt,
              label: 'Foto',
            ),
          ),
          Expanded(
            child: _buildModeButton(
              mode: CaptureMode.gallery,
              icon: Icons.photo_library,
              label: 'Galería',
            ),
          ),
          Expanded(
            child: _buildModeButton(
              mode: CaptureMode.canvas,
              icon: Icons.edit,
              label: 'Dibujar',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required CaptureMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _currentMode = mode;
          if (widget.imagePath != null && mode != CaptureMode.canvas) {
            widget.onRemoveImage();
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1c6b50) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFF514346),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : const Color(0xFF514346),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onTakePhoto,
            icon: const Icon(Icons.camera_alt, size: 20),
            label: const Text('Tomar Foto'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onPickFromGallery,
            icon: const Icon(Icons.photo_library, size: 20),
            label: const Text('Galería'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureArea(BuildContext context) {
    if (_currentMode == CaptureMode.canvas) {
      return DrawingCanvas(
        onDrawingComplete: (imagePath) {
          widget.onCanvasComplete(imagePath);
          setState(() {});
        },
        onClear: () {
          widget.onRemoveImage();
        },
      );
    }

    if (widget.imagePath != null) {
      return _buildImagePreview(context);
    }
    
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFfff0f2),
        border: Border.all(
          color: const Color(0xFFd6c2c5),
          width: 3,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 48,
            color: Color(0xFF514346),
          ),
          const SizedBox(height: 15),
          const Text(
            'Toca para capturar o subir tu trazo',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF514346),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF1c6b50),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Image.file(
              File(widget.imagePath!),
              fit: BoxFit.cover,
              height: 300,
              width: double.infinity,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: widget.onRemoveImage,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFba1a1a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

