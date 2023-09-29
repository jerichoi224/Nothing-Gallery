import 'package:nothing_gallery/classes/Event.dart';
import 'package:nothing_gallery/constants/event_type.dart';
import 'package:photo_manager/photo_manager.dart';

EventType validateEventType(Event event) {
  switch (event.eventType) {
    case EventType.videoOpen:
    case EventType.pictureOpen:
      if (event.details != null && event.details.runtimeType == AssetEntity) {
        return event.eventType;
      }
      break;
    case EventType.pictureDeleted:
      if (event.details != null && event.details.runtimeType == List<String>) {
        return event.eventType;
      }
      break;
    default:
  }
  return EventType.ignore;
}
