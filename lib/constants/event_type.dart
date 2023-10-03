enum EventType {
  assetDeleted,
  pictureOpen,
  videoOpen,
  favoriteAdded,
  favoriteRemoved,
  ignore;

  const EventType({this.detail});
  final dynamic detail;
}
