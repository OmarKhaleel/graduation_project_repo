import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/calculate_bounds.dart';

void updateCameraBounds(
    GoogleMapController controller, List<LatLng> polygonPoints) {
  var bounds = calculateBounds(polygonPoints);
  controller.animateCamera(CameraUpdate.newLatLngBounds(
      bounds, 50)); // 50 is the padding around the edges
}
