import 'package:nothing_gallery/constants/settings_pref.dart';

enum SharedPrefKeys {
  // Settings
  initialScreen(
      text: "initialScreen", type: InitialScreen, onNull: InitialScreen.albums),

  // ImageGridPage
  imageGridPageNumCol(text: "imageGridPageNumCol", type: int, onNull: 4),

  // ImagePage
  useTrashBin(text: "useTrashBin", type: bool, onNull: true),
  favoriteIds(text: "favoriteIds", type: List<String>, onNull: []);

  const SharedPrefKeys(
      {required this.text, required this.type, required this.onNull});

  final String text;
  final Type type;
  final dynamic onNull;
}
