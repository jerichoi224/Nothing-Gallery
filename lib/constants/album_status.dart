enum AlbumState {
  notModified(code: 0),
  itemsDeleted(code: 1);

  const AlbumState({required this.code});
  final int code;
}
