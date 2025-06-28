abstract class MapEvent {}

class LoadCurrentLocationEvent extends MapEvent {
  LoadCurrentLocationEvent();
}

class LoadFirestoreMarkersEvent extends MapEvent {
  LoadFirestoreMarkersEvent();
}
