import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> zoomIntoCluster(
    LatLng clusterCenter, Completer<GoogleMapController> controller) async {
  final GoogleMapController mapController = await controller.future;
  final CameraPosition newCameraPosition = CameraPosition(
    target: clusterCenter,
    zoom: await mapController.getZoomLevel() + 2, // Increase zoom level by 2
  );
  mapController
      .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
}
