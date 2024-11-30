import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:pairtrack/pair_track/domain/services/firebase_service.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/pair_manager.dart';
import 'package:provider/provider.dart';

import 'google_signin_provider.dart';

class UserLocationProvider extends ChangeNotifier {
  FirebaseGroupFunctions firebaseGroupFunctions = FirebaseGroupFunctions();
  double _latitude = 0.0;
  double _longitude = 0.0;
  String locationName = '';
  final CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 15,
  );
  final Completer<GoogleMapController> mapControllerCompleter =
      Completer<GoogleMapController>();

  Future<void> cameraToPosition(LatLng position) async {
    final GoogleMapController controller = await mapControllerCompleter.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: position,
        zoom: 15,
      ),
    ));
    notifyListeners();
  }

  CameraPosition get cameraPosition => _cameraPosition;
  final bool _showLocationSpinner = false;

  double get lat => _latitude;

  String get location => locationName;

  double get long => _longitude;
  bool get spinner => _showLocationSpinner;

  Future<void> getLocationAndUpdates(BuildContext context) async {
    final user = Provider.of<GoogleSignInService>(context, listen: false);
    final pair = Provider.of<ActivePairJoinerManager>(context, listen: false);
    try {
      Location location = Location();
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      _latitude = locationData.latitude!;
      _longitude = locationData.longitude!;
      notifyListeners();
      location.onLocationChanged.listen((LocationData newLocation) {
        if (newLocation.latitude != null && newLocation.longitude != null) {
          firebaseGroupFunctions.updateLocation(
              pair.activePairName,
              user.userEmail,
              LatLng(newLocation.latitude!, newLocation.longitude!));
          _latitude = newLocation.latitude!;
          _longitude = newLocation.longitude!;
          notifyListeners();
        }
      });
      location.changeSettings(
        accuracy: LocationAccuracy.low,
        interval: 5000, // 5 seconds
        distanceFilter: 0, // Update on every movement
      );
    } on Exception {
      return;
    }
  }

  Future getLocationName() async {
    try {
      final url = Uri.parse(
          'http://api.positionstack.com/v1/reverse?access_key=6a7674d0f66fec05fcb5dbc3d4f1af46&query=$lat,$long');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        locationName = decodedData['data'][0]['label'];
        notifyListeners();
      }
    } on Exception {
      return;
    }
  }
}
