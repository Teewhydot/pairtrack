import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedGroup extends ChangeNotifier {
  String? selectedPairID;
  String? get selectedPair => selectedPairID;

  Future<void> loadSelectedGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    selectedPairID = prefs.getString('selectedPairId');
    notifyListeners();
  }

  Future<void> saveSelectedGroupId(String? pairId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPairId', pairId ?? '');
    notifyListeners();
  }
}
