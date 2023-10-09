import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/main.dart';
import 'package:photo_manager/photo_manager.dart';

class AppStatus extends ChangeNotifier {
  int _activeTab = InitialScreen.albums.tabIndex;
  List<String> _favoriteIds = [];
  bool _loading = false;

  int get activeTab => _activeTab;
  bool get loading => _loading;
  List<String> get favoriteIds => _favoriteIds;

  void initialize() {
    _activeTab = sharedPref.get(SharedPrefKeys.initialScreen);
    _favoriteIds =
        List<String>.from(sharedPref.get(SharedPrefKeys.favoriteIds));
    notifyListeners();
    validateFavorites();
  }

  void validateFavorites() async {
    List<String> toRemove = [];
    for (String id in _favoriteIds) {
      final AssetEntity? asset = await AssetEntity.fromId(id);
      if (asset == null) {
        toRemove.add(id);
      }
    }
    removeFavorite(toRemove);
  }

  void addFavorite(List<String> ids) {
    _favoriteIds = List.from(_favoriteIds)..addAll(ids);
    sharedPref.set(SharedPrefKeys.favoriteIds, _favoriteIds);
    notifyListeners();
    // eventController.sink.add(Event(EventType.favoriteAdded, ids)); // No use case
  }

  void removeFavorite(List<String> ids) {
    _favoriteIds = _favoriteIds.toSet().difference(ids.toSet()).toList();
    sharedPref.set(SharedPrefKeys.favoriteIds, _favoriteIds);
    notifyListeners();
    eventController.sink
        .add(Event(EventType.favoriteRemoved, ids)); // No use case
  }

  void setLoading(bool loading) {
    _loading = loading;
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
