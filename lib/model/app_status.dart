import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/constants/constants.dart';
import 'package:nothing_gallery/main.dart';
import 'package:photo_manager/photo_manager.dart';

class AppStatus extends ChangeNotifier {
  int _activeTab = InitialScreen.albums.tabIndex;
  List<String> _favoriteIds = [];
  List<String> _hiddenAblums = [];
  List<String> _customSorting = [];
  Map<String, dynamic> _customThumbnails = {};
  bool _loading = false;

  int get activeTab => _activeTab;
  bool get loading => _loading;
  List<String> get favoriteIds => _favoriteIds;
  List<String> get hiddenAblums => _hiddenAblums;
  List<String> get customSorting => _customSorting;
  Map<String, dynamic> get customThumbnails => _customThumbnails;

  void initialize() {
    _activeTab = sharedPref.get(SharedPrefKeys.initialScreen);
    _favoriteIds =
        List<String>.from(sharedPref.get(SharedPrefKeys.favoriteIds));
    _hiddenAblums =
        List<String>.from(sharedPref.get(SharedPrefKeys.hiddenAlbums));
    _customThumbnails = Map<String, dynamic>.from(
        sharedPref.get(SharedPrefKeys.customThumbnails));
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

  void setCustomSorting(List<String> order) {
    _customSorting = order;
    sharedPref.set(SharedPrefKeys.customSorting, _customSorting);
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
    eventController.sink.add(Event(EventType.favoriteRemoved, ids));
  }

  void setCustomThumbnail(String albumId, String assetId) {
    _customThumbnails[albumId] = assetId;
    sharedPref.set(SharedPrefKeys.customThumbnails, _customThumbnails);
    notifyListeners();
  }

  void removeCustomThumbnail(String albumId) {
    _customThumbnails.remove(albumId);
    sharedPref.set(SharedPrefKeys.customThumbnails, _customThumbnails);
    notifyListeners();
  }

  void addHiddenAblum(List<String> ids) {
    _hiddenAblums = List.from(_hiddenAblums)..addAll(ids);
    sharedPref.set(SharedPrefKeys.hiddenAlbums, _hiddenAblums);
    notifyListeners();
  }

  void removeHiddenAlbum(List<String> ids) {
    _hiddenAblums = _hiddenAblums.toSet().difference(ids.toSet()).toList();
    sharedPref.set(SharedPrefKeys.hiddenAlbums, _hiddenAblums);
    notifyListeners();
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
