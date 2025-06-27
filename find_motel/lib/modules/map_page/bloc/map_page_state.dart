// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState {
  final LatLng center;
  final Set<Marker> markers;
  MapState(this.center, this.markers);
}
