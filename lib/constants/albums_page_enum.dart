enum SortOption {
  recent(text: 'RECENT', id: 0),
  old(text: 'OLD', id: 1),
  nameAscend(text: 'NAME (A-Z)', id: 2),
  nameDescend(text: 'NAME (Z-A)', id: 3);

  const SortOption({required this.text, required this.id});
  final String text;
  final int id;
}
