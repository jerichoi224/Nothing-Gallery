import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission(Permission permission) async {
  PermissionStatus status = await permission.status;

  if (status.isPermanentlyDenied) {
  } else if (status.isDenied) {
    status = await permission.request();
  } else {
    status = await permission.request();
  }
  return status.isGranted || status.isLimited;
}
