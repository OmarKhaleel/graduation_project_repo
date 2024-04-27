import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:palmear_application/domain/entities/user_model.dart';
import 'package:palmear_application/data/repositories/user_repository.dart';
import 'package:palmear_application/data/services/user_session/user_session.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  CameraPosition? initialCameraPosition;
  bool isLoading = true; // To handle loading state
  final Set<Marker> _markers = {};
  late List<LatLng> _polygonPoints;

  @override
  void initState() {
    super.initState();
    setUserLocation();
  }

  Future<void> setUserLocation() async {
    UserModel? sessionUser = UserSession().getUser();
    if (sessionUser != null) {
      UserModel? user = await UserRepository().getUser(sessionUser.uid);
      if (user != null && user.locations.isNotEmpty) {
        double totalLat = 0;
        double totalLng = 0;
        for (LatLng point in user.locations) {
          totalLat += point.latitude;
          totalLng += point.longitude;
        }
        double centroidLat = totalLat / user.locations.length;
        double centroidLng = totalLng / user.locations.length;

        // Set the first location from the list
        initialCameraPosition = CameraPosition(
          target: LatLng(centroidLat, centroidLng),
          zoom: 17,
        );
        Marker userFarmLocationMarker = Marker(
          markerId: const MarkerId("_userFarmLocationMarker"),
          infoWindow: const InfoWindow(title: "Your Farm's Location"),
          icon: BitmapDescriptor.defaultMarker,
          position: LatLng(centroidLat, centroidLng),
        );
        _markers.add(userFarmLocationMarker);
        _polygonPoints = user.locations;
      } else {
        // Default location if user or user location is not found
        initialCameraPosition = const CameraPosition(
          target: LatLng(31.99514837693595, 35.879547964711016),
          zoom: 18,
        );
      }
      isLoading = false; // Set loading to false after location is set
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isLoading
          ? GoogleMap(
              markers: _markers,
              polygons: {
                Polygon(
                  polygonId: const PolygonId("1"),
                  points: _polygonPoints,
                  fillColor: const Color(0xFF00916E).withOpacity(0.80),
                  strokeWidth: 2,
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: initialCameraPosition!,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
