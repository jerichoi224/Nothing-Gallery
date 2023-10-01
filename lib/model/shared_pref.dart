import 'package:shared_preferences/shared_preferences.dart';

import 'package:nothing_gallery/constants/constants.dart';

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
    if (value.runtimeType == String) {
      prefs.setString(key, value);
    } else if (value.runtimeType == double) {
      prefs.setDouble(key, value);
    } else if (value.runtimeType == bool) {
      prefs.setBool(key, value);
    } else if (value.runtimeType == int) {
      prefs.setInt(key, value);
    } else if (value.runtimeType == List<String>) {
      prefs.setStringList(key, value);
    }
    prefMap[key] = value;
  }

  dynamic get(SharedPrefKeys spKey) {
    String key = spKey.text;
    if (!prefMap.keys.contains(key)) {
      return spKey.onNull;
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
