// import 'dart:async';
// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
//
// class ConnectivityService {
//   final InternetConnection _internetChecker = InternetConnection();
//   final StreamController<bool> _connectivityStreamController =
//       StreamController<bool>();
//
//   ConnectivityService() {
//     _internetChecker.onStatusChange.listen((status) {
//       _connectivityStreamController.add(status == InternetStatus.connected);
//     });
//   }
//
//   Stream<bool> get connectivityStream => _connectivityStreamController.stream;
//
//   void dispose() {
//     _connectivityStreamController.close();
//   }
// }
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService with ChangeNotifier {
  final InternetConnection _internetChecker = InternetConnection();
  bool _isConnected = true;

  ConnectivityService() {
    _internetChecker.onStatusChange.listen((status) {
      _isConnected = status == InternetStatus.connected;
      notifyListeners();
    });
  }

  bool get isConnected => _isConnected;
}