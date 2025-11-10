import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestPhotoLibraryPermission() async {
    if (await Permission.photos.isGranted) {
      return true;
    }
    
    final photosStatus = await Permission.photos.request();
    if (photosStatus.isGranted) return true;
    
    if (photosStatus.isPermanentlyDenied) {
      return false;
    }
    
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  static Future<bool> hasPhotoLibraryPermission() async {
    final photosStatus = await Permission.photos.status;
    if (photosStatus.isGranted) return true;
    
    final storageStatus = await Permission.storage.status;
    return storageStatus.isGranted;
  }
}

