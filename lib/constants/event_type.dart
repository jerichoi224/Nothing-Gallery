enum EventType {
  pictureDeleted,
  pictureOpen,
  videoOpen,
  albumEmpty,
  ignore;

  const EventType({this.detail});
  final dynamic detail;
}
