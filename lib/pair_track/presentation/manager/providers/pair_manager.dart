import 'package:flutter/cupertino.dart';

class ActivePairJoinerManager extends ChangeNotifier {
  String? activePairName;
  int numOfMembers = 0;

  void updateNumOfMembersForActivePair(int members) {
    numOfMembers = members;
    notifyListeners();
  }

  void updateActivePair(String selectedPair) {
    activePairName = selectedPair;
    notifyListeners();
  }
}
