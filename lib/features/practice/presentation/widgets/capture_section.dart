import 'dart:io';
import 'package:flutter/material.dart';
import 'drawing_canvas.dart';

enum CaptureMode { camera, drawing }

class CaptureSection extends StatefulWidget {
  final String? imagePath;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickFromGallery;
  final VoidCallback onRemoveImage;
  final Function(String) onDrawingSaved;

  const CaptureSection({
    super.key,
    this.imagePath,
    required this.onTakePhoto,
    required this.onPickFromGallery,
    required this.onRemoveImage,
    required this.onDrawingSaved,
  });

  @override
  State<CaptureSection> createState() => _CaptureSectionState();
}

class _CaptureSectionState extends State<CaptureSection> {
  CaptureMode _currentMode = CaptureMode.camera;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        
        // Área de captura, dibujo o imagen
        _buildCaptureArea(context),
        
        const SizedBox(height: 15),
        
        // Botones de acción según el modo
        if (_currentMode == CaptureMode.camera) _buildCameraButtons(),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFfff0f2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFd6c2c5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              mode: CaptureMode.camera,
              icon: Icons.camera_alt,
              label: 'Cámara',
            ),
          ),
          Expanded(
            child: _buildModeButton(
              mode: CaptureMode.drawing,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentMode = mode;
            if (mode == CaptureMode.camera && widget.imagePath != null) {
              widget.onRemoveImage();
            }
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8d4a5b) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF514346),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : const Color(0xFF514346),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onTakePhoto,
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text(
              'Tomar Foto',
              style: TextStyle(fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(0, 44),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onPickFromGallery,
            icon: const Icon(Icons.photo_library, size: 18),
            label: const Text(
              'Galería',
              style: TextStyle(fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(0, 44),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureArea(BuildContext context) {
    if (_currentMode == CaptureMode.drawing) {
      return DrawingCanvas(
        onDrawingComplete: (imagePath) {
          widget.onDrawingSaved(imagePath);
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
        mainAxisSize: MainAxisSize.min,
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

