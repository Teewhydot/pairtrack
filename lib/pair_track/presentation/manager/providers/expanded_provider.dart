import 'package:flutter/material.dart';

class TrayExpanded extends ChangeNotifier {
  bool expanded = false;
  bool get isExpanded => expanded;

  void toggleExpanded() {
    expanded = !expanded;
    notifyListeners();
  }
}
