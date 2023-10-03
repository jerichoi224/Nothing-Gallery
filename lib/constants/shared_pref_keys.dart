enum SharedPrefKeys {
  // Settings
  initialScreen(text: "initialScreenIndex", type: int, onNull: 1),

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
