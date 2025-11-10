import 'dart:io';
import 'package:flutter/material.dart';

class CaptureSection extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickFromGallery;
  final VoidCallback onRemoveImage;

  const CaptureSection({
    super.key,
    this.imagePath,
    required this.onTakePhoto,
    required this.onPickFromGallery,
    required this.onRemoveImage,
  });

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
        
        // Área de captura o imagen
        _buildCaptureArea(context),
        
        const SizedBox(height: 15),
        
        // Botones de acción
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTakePhoto,
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
                onPressed: onPickFromGallery,
                icon: const Icon(Icons.photo_library, size: 20),
                label: const Text('Galería'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaptureArea(BuildContext context) {
    if (imagePath != null) {
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
              File(imagePath!),
              fit: BoxFit.cover,
              height: 300,
              width: double.infinity,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: onRemoveImage,
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

