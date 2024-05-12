import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLng calculateCentroid(List<LatLng> points) {
  double latitudeSum = 0.0;
  double longitudeSum = 0.0;
  for (LatLng point in points) {
    latitudeSum += point.latitude;
    longitudeSum += point.longitude;
  }
  return LatLng(latitudeSum / points.length, longitudeSum / points.length);
}
