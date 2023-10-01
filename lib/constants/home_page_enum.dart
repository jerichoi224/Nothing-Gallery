enum HomeTabMenu {
  pictures(text: 'TIMELINE'),
  albums(text: 'ALBUMS');

  const HomeTabMenu({required this.text});
  final String text;
}

enum HomePopupMenu {
  settings(text: 'SETTINGS');

  const HomePopupMenu({required this.text});
  final String text;
}
