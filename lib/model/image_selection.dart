import 'package:flutter/material.dart';

class ImageSelection extends ChangeNotifier {
  List<String> _selectedIds = [];
  bool _selectionMode = false;

  bool get selectionMode => _selectionMode;
  List<String> get selectedIds => _selectedIds;

  void startSelection() {
    _selectionMode = true;
    notifyListeners();
  }

  void endSelection() {
    _selectedIds.clear();
    _selectionMode = false;
    notifyListeners();
  }

  void addSelection(List<String> ids) {
    _selectedIds = List.from(_selectedIds)..addAll(ids);
    notifyListeners();
  }

  void removeSelection(List<String> ids) {
    _selectedIds = _selectedIds.toSet().difference(ids.toSet()).toList();
    notifyListeners();
  }
}
