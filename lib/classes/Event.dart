import 'package:nothing_gallery/constants/eventType.dart';

class Event {
  EventType? eventType;
  dynamic details;

  Event(this.eventType, this.details);
}
