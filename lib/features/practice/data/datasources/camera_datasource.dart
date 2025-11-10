import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

abstract class CameraDataSource {
  Future<List<CameraDescription>> getAvailableCameras();
  Future<CameraController> initializeCamera(CameraDescription camera);
  Future<File> takePicture(CameraController controller);
}

class CameraDataSourceImpl implements CameraDataSource {
  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      throw CameraException('Error al obtener las cámaras disponibles: ${e.toString()}');
    }
  }

  @override
  Future<CameraController> initializeCamera(CameraDescription camera) async {
    try {
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      return controller;
    } catch (e) {
      throw CameraException('Error al inicializar la cámara: ${e.toString()}');
    }
  }

  @override
  Future<File> takePicture(CameraController controller) async {
    try {
      if (!controller.value.isInitialized) {
        throw const CameraException('La cámara no está inicializada');
      }

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'handwriting_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(appDir.path, fileName);

      final XFile image = await controller.takePicture();
      final File imageFile = File(image.path);
      
      // Copiar la imagen a la ubicación deseada
      await imageFile.copy(filePath);
      
      return File(filePath);
    } catch (e) {
      if (e is CameraException) rethrow;
      throw CameraException('Error al tomar la foto: ${e.toString()}');
    }
  }
}

class CameraException implements Exception {
  final String message;
  const CameraException(this.message);
}

