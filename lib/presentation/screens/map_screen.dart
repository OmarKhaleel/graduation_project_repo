import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:palmear_application/data/repositories/farm_repository.dart';
import 'package:palmear_application/data/repositories/tree_repository.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';
import 'package:palmear_application/domain/entities/farm_model.dart';
import 'package:palmear_application/domain/entities/tree_model.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/calculate_centroid.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/marker_builder.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/update_camera_bounds.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';

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
  bool hasInternet = true;
  List<TreeModel> treesList = [];
  late Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};
  List<LatLng> _polygonPoints = [];
  late StreamSubscription<List<FarmModel>> _farmSubscription; // Declared here

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _setFarmLocations();
    _manager = _initClusterManager();
  }

  void _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    hasInternet = connectivityResult != ConnectivityResult.none;
    showToast(message: "$hasInternet");
  }

  Future<void> _setFarmLocations() async {
    var sessionUser = UserSession().getUser();
    if (sessionUser != null) {
      var farmRepository = FarmRepository(userId: sessionUser.uid);
      _farmSubscription = farmRepository.getFarmsStream().listen((farms) async {
        List<LatLng> updatedPolygonPoints = [];
        List<TreeModel> updatedTreesList = [];

        if (farms.isNotEmpty) {
          for (var farm in farms) {
            updatedPolygonPoints.addAll(farm.locations);
            var treeRepository =
                TreeRepository(userId: sessionUser.uid, farmId: farm.uid);

            // Fetch initial trees data
            List<TreeModel> initialTrees = await treeRepository.getTrees();
            updatedTreesList.addAll(initialTrees);

            // Stream subscription for trees
            treeRepository.getTreesStream().listen((trees) {
              if (mounted) {
                setState(() {
                  treesList = trees;
                  _manager.setItems(treesList); // Update the Cluster Manager
                });
              }
            });
          }

          if (mounted) {
            setState(() {
              _polygonPoints = updatedPolygonPoints;

              // Calculate the centroid of the polygon
              LatLng centroid = calculateCentroid(_polygonPoints);

              initialCameraPosition = CameraPosition(
                target: centroid,
                zoom: 6,
              );

              _polygons.clear();
              _polygons.add(Polygon(
                polygonId: const PolygonId("farmPolygon"),
                points: _polygonPoints,
                fillColor: const Color(0xFF00916E).withOpacity(0.80),
                strokeWidth: 2,
              ));

              // Later adjust the zoom to fit the polygon
              _controller.future.then((controller) {
                updateCameraBounds(controller, _polygonPoints);
              });
            });
          }
        } else {
          if (mounted) {
            setState(() {
              initialCameraPosition = const CameraPosition(
                target: LatLng(31.99514837693595, 35.879547964711016),
                zoom: 18,
              );
              _polygonPoints.clear();
              treesList.clear();
            });
          }
        }
        isLoading = false;
        if (mounted) {
          setState(() {});
        }
      });
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
    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  @override
  void dispose() {
    _controller.future.then((controller) => controller.dispose());
    _farmSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: hasInternet
            ? !isLoading
                ? GoogleMap(
                    mapType: MapType.normal,
                    markers: _markers,
                    polygons: _polygons,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    initialCameraPosition: initialCameraPosition!,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      _manager.setMapId(controller.mapId);
                    },
                    onCameraMove: _manager.onCameraMove,
                    onCameraIdle: _manager.updateMap,
                  )
                : const Center(child: CircularProgressIndicator())
            : const Center(
                child: Text(
                    "Offline Map View")) // Placeholder for offline map view
        );
  }
}
