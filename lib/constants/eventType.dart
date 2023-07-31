enum EventType {
  pictureDeleted,
  albumEmpty;

  const EventType({this.detail});
  final dynamic detail;
}
