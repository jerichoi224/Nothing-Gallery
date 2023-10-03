import 'package:photo_manager/photo_manager.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/constants/constants.dart';

EventType validateEventType(Event event) {
  switch (event.eventType) {
    case EventType.videoOpen:
    case EventType.pictureOpen:
      if (event.details != null && event.details.runtimeType == AssetEntity) {
        return event.eventType;
      }
      break;
    case EventType.favoriteRemoved:
    case EventType.assetDeleted:
      if (event.details != null && event.details.runtimeType == List<String>) {
        return event.eventType;
      }
      break;
    default:
  }
  return EventType.ignore;
}
