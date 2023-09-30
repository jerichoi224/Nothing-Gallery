enum EventType {
  assetDeleted,
  pictureOpen,
  videoOpen,
  albumEmpty,
  ignore;

  const EventType({this.detail});
  final dynamic detail;
}
