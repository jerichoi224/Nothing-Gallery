enum AlbumState {
  notModified(code: 0),
  itemsDeleted(code: 1),
  albumEmpty(code: 3);

  const AlbumState({required this.code});
  final int code;
}
