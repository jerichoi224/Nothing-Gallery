enum EventType {
  assetDeleted,
  pictureOpen,
  videoOpen,
  ignore;

  const EventType({this.detail});
  final dynamic detail;
}
