enum InitialScreen {
  timeline(
    tabIndex: 0,
  ),
  albums(tabIndex: 1);

  const InitialScreen({required this.tabIndex});
  final int tabIndex;
}
