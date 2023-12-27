import 'package:permission_handler/permission_handler.dart';

enum LocationPermissionStatus { granted, denied, permanentlyDenied, restricted }

class LocationPermissionsHandler {
  Future<bool> get isGranted async {
    final status = await Permission.location.status;
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

  Future<bool> get isAlwaysGranted {
    return Permission.locationAlways.isGranted;
  }

  Future<LocationPermissionStatus> request() async {
    final status = await Permission.location.request();
    switch (status) {
      case PermissionStatus.granted:
        return LocationPermissionStatus.granted;
      case PermissionStatus.denied:
        return LocationPermissionStatus.denied;
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        return LocationPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
        return LocationPermissionStatus.restricted;
      default:
        return LocationPermissionStatus.denied;
    }
  }
}
