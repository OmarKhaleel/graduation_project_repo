import 'package:geolocator/geolocator.dart';

// Define the function to check permissions
Future<bool> checkPermission() async {
  bool isEnable = false;
  LocationPermission permission;

  // Check if location is enabled
  isEnable = await Geolocator.isLocationServiceEnabled();
  if (!isEnable) {
    return false;
  }

  // Check if the user allows location permission
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    // If permission is denied then request the user to allow permission again
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // If permission denied again
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return false;
  }

  return true;
}
