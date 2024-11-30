import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService extends ChangeNotifier {
  bool isLocationPermissionGranted = false;
  bool isBackgroundLocationPermissionGranted = false;
  bool isNotificationPermissionGranted = false;

  bool get locationPermissionGranted => isLocationPermissionGranted;
  bool get backgroundLocationPermissionGranted => isBackgroundLocationPermissionGranted;
  bool get notificationPermissionGranted => isNotificationPermissionGranted;

  PermissionService() {
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    isLocationPermissionGranted = prefs.getBool('locationPermissionGranted') ?? false;
    isBackgroundLocationPermissionGranted = prefs.getBool('backgroundLocationPermissionGranted') ?? false;
    isNotificationPermissionGranted = prefs.getBool('notificationPermissionGranted') ?? false;
    notifyListeners();
  }

  Future<void> _savePermissions() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('locationPermissionGranted', isLocationPermissionGranted);
    prefs.setBool('backgroundLocationPermissionGranted', isBackgroundLocationPermissionGranted);
    prefs.setBool('notificationPermissionGranted', isNotificationPermissionGranted);
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    isLocationPermissionGranted = status.isGranted;
    await _savePermissions();
    notifyListeners();
  }

  Future<void> requestBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.request();
    isBackgroundLocationPermissionGranted = status.isGranted;
    await _savePermissions();
    notifyListeners();
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    isNotificationPermissionGranted = status.isGranted;
    await _savePermissions();
    notifyListeners();
  }
}