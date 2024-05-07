import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:palmear_application/data/repositories/farm_repository.dart';
import 'package:palmear_application/data/repositories/tree_repository.dart';
import 'package:palmear_application/data/services/user_session/user_session.dart';
import 'package:palmear_application/domain/entities/tree_model.dart';
import 'package:palmear_application/domain/use_cases/marker_builder.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late ClusterManager _manager;
  final Completer<GoogleMapController> _controller = Completer();
  CameraPosition? initialCameraPosition;
  bool isLoading = true; // To handle loading state
  final List<TreeModel> treesList = [];
  late Set<Marker> markers = {};
  final Set<Polygon> _polygons = {};
  final List<LatLng> _polygonPoints = [];

  @override
  void initState() {
    super.initState();
    _setFarmLocations();
    _manager = _initClusterManager();
  }

  Future<void> _setFarmLocations() async {
    var sessionUser = UserSession().getUser();
    if (sessionUser != null) {
      var farmRepository = FarmRepository(userId: sessionUser.uid);
      var farms = await farmRepository
          .getFarms(); // This method needs to be implemented in FarmRepository
      if (farms.isNotEmpty) {
        for (var farm in farms) {
          _polygonPoints.addAll(farm.locations);
          var treeRepository =
              TreeRepository(userId: sessionUser.uid, farmId: farm.uid);
          var trees = await treeRepository.getTrees();
          if (trees.isNotEmpty) {
            for (var tree in trees) {
              treesList.add(tree);
            }
          }
        }
        // Assuming the centroid or any point for the initial camera position
        initialCameraPosition = CameraPosition(
          target: _polygonPoints.first,
          zoom: 17,
        );

        _polygons.add(Polygon(
          polygonId: const PolygonId("farmPolygon"),
          points: _polygonPoints,
          fillColor: const Color(0xFF00916E).withOpacity(0.80),
          strokeWidth: 2,
        ));
      } else {
        // Default location if no farms are found
        initialCameraPosition = const CameraPosition(
          target: LatLng(31.99514837693595, 35.879547964711016),
          zoom: 18,
        );
      }
      isLoading = false;
      setState(() {});
    }
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<TreeModel>(
      treesList,
      _updateMarkers,
      markerBuilder: markerBuilder(_controller),
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      this.markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isLoading
          ? GoogleMap(
              mapType: MapType.normal,
              markers: markers,
              polygons: _polygons,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              initialCameraPosition: initialCameraPosition!,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                _manager.setMapId(controller.mapId);
              },
              onCameraMove: _manager.onCameraMove,
              onCameraIdle: _manager.updateMap)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
