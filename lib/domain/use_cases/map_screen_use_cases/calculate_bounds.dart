import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLngBounds calculateBounds(List<LatLng> points) {
  double north = -double.infinity;
  double south = double.infinity;
  double east = -double.infinity;
  double west = double.infinity;

  for (LatLng point in points) {
    if (point.latitude > north) north = point.latitude;
    if (point.latitude < south) south = point.latitude;
    if (point.longitude > east) east = point.longitude;
    if (point.longitude < west) west = point.longitude;
  }

  return LatLngBounds(
    northeast: LatLng(north, east),
    southwest: LatLng(south, west),
  );
}
