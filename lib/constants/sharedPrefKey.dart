enum SharedPrefKeys {
  // Settings
  hasPermission(text: "hasPermission", type: bool),

  // ImageGridPage
  imageGridPageNumCol(text: "imageGridPageNumCol", type: int);

  const SharedPrefKeys({required this.text, required this.type});

  final String text;
  final Type type;
}
