import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission(Permission permission) async {
  PermissionStatus status = await permission.status;

  if (status.isPermanentlyDenied) {
    print("Permission is permanently denied");
    return false;
  } else if (status.isDenied) {
    print("Permission is denied");
    status = await permission.request();
    print("Permission status on requesting again: $status");
  } else {
    print("Permission is not permanently denied");
    status = await permission.request();
  }
  return status.isGranted || status.isLimited;
}
