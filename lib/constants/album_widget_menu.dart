enum AlbumWidgetMenu {
  changeThumbnail(text: 'CHANGE THUMBNAIL'),
  hideAlbum(text: 'HIDE ALBUM');

  const AlbumWidgetMenu({required this.text});
  final String text;
}
