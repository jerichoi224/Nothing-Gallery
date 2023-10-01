import 'package:nothing_gallery/constants/event_type.dart';

class Event {
  EventType eventType;
  dynamic details;

  Event(this.eventType, this.details);
}
