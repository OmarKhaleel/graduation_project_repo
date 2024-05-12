import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> centerAndZoomIn(
    LatLng position, Completer<GoogleMapController> controller) async {
  final GoogleMapController mapController = await controller.future;
  final double currentZoom = await mapController.getZoomLevel();
  final CameraPosition newCameraPosition = CameraPosition(
    target: position,
    zoom: currentZoom + 2, // Adjust the zoom increment as needed
  );
  mapController
      .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
}
