import 'package:flutter/material.dart';

class ImageSelection extends ChangeNotifier {
  List<String> _selectedIds = [];
  bool _selectionMode = false;

  bool get selectionMode => _selectionMode;
  List<String> get selectedIds => _selectedIds;
  int get selectedCount => _selectedIds.length;

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

  void setSelection(List<String> ids) {
    _selectedIds = ids;
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  void removeSelection(List<String> ids) {
    _selectedIds = _selectedIds.toSet().difference(ids.toSet()).toList();
    notifyListeners();
  }
}
