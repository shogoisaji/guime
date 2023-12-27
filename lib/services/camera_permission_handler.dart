import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionStatus { granted, denied, restricted, limited, permanentlyDenied }

class CameraPermissionsHandler {
  Future<bool> get isGranted async {
    final status = await Permission.camera.status;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return true;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        return false;
      default:
        return false;
    }
  }

  Future<CameraPermissionStatus> request() async {
    final status = await Permission.camera.request();
    switch (status) {
      case PermissionStatus.granted:
        return CameraPermissionStatus.granted;
      case PermissionStatus.denied:
        return CameraPermissionStatus.denied;
      case PermissionStatus.limited:
        return CameraPermissionStatus.limited;
      case PermissionStatus.restricted:
        return CameraPermissionStatus.restricted;
      case PermissionStatus.permanentlyDenied:
        return CameraPermissionStatus.permanentlyDenied;
      default:
        return CameraPermissionStatus.denied;
    }
  }
}
