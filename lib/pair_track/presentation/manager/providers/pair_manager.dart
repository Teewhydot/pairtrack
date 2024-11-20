import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pairtrack/pair_track/domain/services/firebase_service.dart';

class ActivePairJoinerManager extends ChangeNotifier {
  FirebaseGroupFunctions firebaseGroupFunctions  = FirebaseGroupFunctions();
  LatLng? activePairJoiner;
  String? activePairName;
  Marker? activePairJoinerMarker;

  void updateActivePair(String selectedPair) {
    activePairName = selectedPair;
    notifyListeners();
  }

  void setPairJoiner(LatLng pairJoiner) {
    activePairJoiner = pairJoiner;
    notifyListeners();
  }
}
