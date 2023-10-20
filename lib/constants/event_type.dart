enum EventType {
  assetDeleted,
  // assetCopied,
  assetMoved,
  pictureOpen,
  videoOpen,
  favoriteAdded,
  favoriteRemoved,
  hiddenAblumChanged,
  settingsChanged,
  ignore;

  const EventType({this.detail});
  final dynamic detail;
}
