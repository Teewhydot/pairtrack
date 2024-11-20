import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class LocationProvider extends ChangeNotifier {
  double _latitude = 0.0;
  double _longitude = 0.0;
  String locationName = '';
  CameraPosition _cameraPosition = const CameraPosition(
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

  Future<void> fetchLocationUpdates() async {

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
          _latitude = newLocation.latitude!;
          _longitude = newLocation.longitude!;
          _cameraPosition = CameraPosition(
            target: LatLng(_latitude, _longitude),
            zoom: 15,
          );
          notifyListeners();
        }
      });
      location.enableBackgroundMode(enable: true);
      location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 100,
        distanceFilter: 1,
      );
    } catch (e) {
      print(e);
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
      }
    } on Exception {}
    notifyListeners();
  }
}
