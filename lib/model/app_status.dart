import 'package:flutter/material.dart';

class AppStatus extends ChangeNotifier {
  int _activeTab = 1;

  int get activeTab => _activeTab;

  void setActiveTab(int i) {
    _activeTab = i;
    notifyListeners();
  }
}
