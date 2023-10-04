enum EventType {
  assetDeleted,
  pictureOpen,
  videoOpen,
  favoriteAdded,
  favoriteRemoved,
  settingsChanged,
  ignore;

  const EventType({this.detail});
  final dynamic detail;
}
