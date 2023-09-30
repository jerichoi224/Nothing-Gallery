enum HomeTabMenu {
  pictures(text: 'PICTURES'),
  albums(text: 'ALBUMS');

  const HomeTabMenu({required this.text});
  final String text;
}

enum HomePopupMenu {
  settings(text: 'SETTINGS');

  const HomePopupMenu({required this.text});
  final String text;
}
