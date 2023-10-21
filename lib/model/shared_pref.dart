import 'package:shared_preferences/shared_preferences.dart';

import 'package:nothing_gallery/constants/constants.dart';
import 'dart:convert';

class SharedPref {
  late final SharedPreferences prefs;
  Map<String, dynamic> prefMap = {};
  SharedPref._create(this.prefs) {
    init();
  }

  void init() {
    for (String key in prefs.getKeys()) {
      prefMap[key] = prefs.get(key);
    }
  }

  void set(SharedPrefKeys spKey, dynamic value) {
    String key = spKey.text;
    if (value is String) {
      prefs.setString(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is List<String>) {
      prefs.setStringList(key, value);
    } else if (value is Map<String, dynamic>) {
      String encodedMap = json.encode(value);
      prefs.setString(key, encodedMap);
    }
    prefMap[key] = value;
  }

  dynamic get(SharedPrefKeys spKey) {
    String key = spKey.text;
    if (!prefMap.keys.contains(key)) {
      return spKey.onNull;
    }

    if (spKey.type == Map<String, dynamic>) {
      return json.decode(prefMap[key]);
    }
    return prefMap[key];
  }

  static Future<SharedPref> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPref._create(prefs);
  }

  restartDB() async {
    init();
  }
}
