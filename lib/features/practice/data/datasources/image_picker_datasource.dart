import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/permission_service.dart';

abstract class ImagePickerDataSource {
  Future<File> pickImageFromCamera();
  Future<File> pickImageFromGallery();
}

class ImagePickerDataSourceImpl implements ImagePickerDataSource {
  final ImagePicker _imagePicker;

  ImagePickerDataSourceImpl(this._imagePicker);

  @override
  Future<File> pickImageFromCamera() async {
    try {
      // Solicitar permiso de cámara
      final hasPermission = await PermissionService.requestCameraPermission();
      if (!hasPermission) {
        throw const ImagePickerException(
          'Se requiere permiso de cámara para capturar imágenes',
        );
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) {
        throw const ImagePickerException('No se seleccionó ninguna imagen');
      }

      return File(image.path);
    } catch (e) {
      if (e is ImagePickerException) rethrow;
      throw ImagePickerException('Error al capturar la imagen: ${e.toString()}');
    }
  }

  @override
  Future<File> pickImageFromGallery() async {
    try {
      // Solicitar permiso de galería
      final hasPermission = await PermissionService.requestPhotoLibraryPermission();
      if (!hasPermission) {
        throw const ImagePickerException(
          'Se requiere permiso de galería para seleccionar imágenes',
        );
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        throw const ImagePickerException('No se seleccionó ninguna imagen');
      }

      return File(image.path);
    } catch (e) {
      if (e is ImagePickerException) rethrow;
      throw ImagePickerException('Error al seleccionar la imagen: ${e.toString()}');
    }
  }
}

class ImagePickerException implements Exception {
  final String message;
  const ImagePickerException(this.message);
}

