import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends ChangeNotifier {
   bool isLocationPermissionGranted = false;
   bool isBackgroundLocationPermissionGranted = false;
   bool isNotificationPermissionGranted = false;

  bool get locationPermissionGranted => isLocationPermissionGranted;
  bool get backgroundLocationPermissionGranted =>
      isBackgroundLocationPermissionGranted;
  bool get notificationPermissionGranted => isNotificationPermissionGranted;

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    isLocationPermissionGranted = status.isGranted;
    notifyListeners();
  }

  Future<void> requestBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.request();
    isBackgroundLocationPermissionGranted = status.isGranted;
    notifyListeners();
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    isNotificationPermissionGranted = status.isGranted;
    notifyListeners();
  }

   Future<void> openAppSettings() async {
     await openAppSettings();
   }
}
