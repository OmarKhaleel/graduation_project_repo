import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/location_permission.dart';

Future<Position?> getUserLocation() async {
  debugPrint("Fetching location...");
  var isEnable = await checkPermission();
  if (isEnable) {
    Position currentLocation = await Geolocator.getCurrentPosition();
    debugPrint(
        "Location: Lat: ${currentLocation.latitude}, Lng: ${currentLocation.longitude}");
    return currentLocation;
  } else {
    debugPrint("Location permission denied");
    return null;
  }
}
