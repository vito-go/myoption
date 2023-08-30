import 'dart:async';

final StreamController<GlobalEvent> _globalEventBroadcast =
    StreamController.broadcast();

enum GlobalEventType {
  dataNetworkChange,
  timeNow,
}

addToGlobalEvent(GlobalEvent event) {
  _globalEventBroadcast.add(event);
}

StreamSubscription<GlobalEvent> subscriptGlobalEvent(
    Function(GlobalEvent event) onData) {
  return _globalEventBroadcast.stream.listen(onData);
}

class GlobalEvent {
  GlobalEventType eventType;
  dynamic param;

  GlobalEvent({required this.eventType, required this.param});
}
