import 'package:flutter/material.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/main.dart';

class AppStatus extends ChangeNotifier {
  int _activeTab = 1;
  List<String> _favoriteIds = [];

  int get activeTab => _activeTab;
  List<String> get favoriteIds => _favoriteIds;

  void initialize() {
    _activeTab = (sharedPref.get(SharedPrefKeys.initialScreen) as InitialScreen)
        .tabIndex;
    _favoriteIds =
        List<String>.from(sharedPref.get(SharedPrefKeys.favoriteIds));
    notifyListeners();
  }

  void addFavorite(List<String> ids) {
    _favoriteIds = List.from(_favoriteIds)..addAll(ids);
    sharedPref.set(SharedPrefKeys.favoriteIds, _favoriteIds);
    notifyListeners();
  }

  void removeFavorite(List<String> ids) {
    _favoriteIds = _favoriteIds.toSet().difference(ids.toSet()).toList();
    sharedPref.set(SharedPrefKeys.favoriteIds, _favoriteIds);
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  void setActiveTab(int i) {
    _activeTab = i;
    notifyListeners();
  }
}
