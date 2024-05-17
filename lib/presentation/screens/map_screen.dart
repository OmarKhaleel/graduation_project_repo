// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart' as osm;
// import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
// import 'package:latlong2/latlong.dart' as latlng;
// import 'package:palmear_application/data/repositories/farm_repository.dart';
// import 'package:palmear_application/data/repositories/tree_repository.dart';
// import 'package:palmear_application/data/services/firestore_services/connectivity_service.dart';
// import 'package:palmear_application/data/services/user_services/user_session.dart';
// import 'package:palmear_application/domain/entities/farm_model.dart';
// import 'package:palmear_application/domain/entities/tree_model.dart';
// import 'package:palmear_application/domain/use_cases/map_screen_use_cases/calculate_centroid.dart';
// import 'package:palmear_application/domain/use_cases/map_screen_use_cases/marker_builder.dart';
// import 'package:palmear_application/domain/use_cases/map_screen_use_cases/update_camera_bounds.dart';
// import 'package:provider/provider.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late ClusterManager _manager;
//   Completer<gmaps.GoogleMapController> _controller = Completer();
//   gmaps.CameraPosition? initialCameraPosition;
//   bool isLoading = true; // To handle loading state
//   bool hasInternet = true;
//   List<TreeModel> treesList = [];
//   late Set<gmaps.Marker> _markers = {};
//   final Set<gmaps.Polygon> _polygons = {};
//   List<gmaps.LatLng> _polygonPoints = [];
//   late StreamSubscription<List<FarmModel>> _farmSubscription; // Declared here
//   late VoidCallback _connectivityListener;

//   @override
//   void initState() {
//     super.initState();
//     _setFarmLocations();
//     _manager = _initClusterManager();

//     _connectivityListener = () {
//       if (mounted) {
//         bool isConnected = context.read<ConnectivityService>().isConnected;
//         if (isConnected) {
//           _resetMapController();
//           _manager = _initClusterManager();
//         }
//       }
//     };

//     context.read<ConnectivityService>().addListener(_connectivityListener);
//   }

//   Future<void> _setFarmLocations() async {
//     var sessionUser = UserSession().getUser();
//     if (sessionUser != null) {
//       var farmRepository = FarmRepository(userId: sessionUser.uid);
//       _farmSubscription = farmRepository.getFarmsStream().listen((farms) async {
//         List<gmaps.LatLng> updatedPolygonPoints = [];
//         List<TreeModel> updatedTreesList = [];

//         if (farms.isNotEmpty) {
//           for (var farm in farms) {
//             updatedPolygonPoints.addAll(farm.locations);
//             var treeRepository =
//                 TreeRepository(userId: sessionUser.uid, farmId: farm.uid);

//             // Fetch initial trees data
//             List<TreeModel> initialTrees = await treeRepository.getTrees();
//             updatedTreesList.addAll(initialTrees);

//             // Stream subscription for trees
//             treeRepository.getTreesStream().listen((trees) {
//               if (mounted) {
//                 setState(() {
//                   treesList = trees;
//                   _manager.setItems(treesList); // Update the Cluster Manager
//                 });
//               }
//             });
//           }

//           if (mounted) {
//             setState(() {
//               _polygonPoints = updatedPolygonPoints;

//               // Calculate the centroid of the polygon
//               gmaps.LatLng centroid = calculateCentroid(_polygonPoints);

//               initialCameraPosition = gmaps.CameraPosition(
//                 target: centroid,
//                 zoom: 6,
//               );

//               _polygons.clear();
//               _polygons.add(gmaps.Polygon(
//                 polygonId: const gmaps.PolygonId("farmPolygon"),
//                 points: _polygonPoints,
//                 fillColor: const Color(0xFF00916E).withOpacity(0.80),
//                 strokeWidth: 2,
//               ));

//               // Later adjust the zoom to fit the polygon
//               _controller.future.then((controller) {
//                 updateCameraBounds(controller, _polygonPoints);
//               });
//             });
//           }
//         } else {
//           if (mounted) {
//             setState(() {
//               initialCameraPosition = const gmaps.CameraPosition(
//                 target: gmaps.LatLng(31.99514837693595, 35.879547964711016),
//                 zoom: 18,
//               );
//               _polygonPoints.clear();
//               treesList.clear();
//             });
//           }
//         }
//         isLoading = false;
//         if (mounted) {
//           setState(() {});
//         }
//       });
//     }
//   }

//   ClusterManager _initClusterManager() {
//     return ClusterManager<TreeModel>(
//       treesList,
//       _updateMarkers,
//       markerBuilder: markerBuilder(_controller),
//     );
//   }

//   void _updateMarkers(Set<gmaps.Marker> markers) {
//     if (mounted) {
//       setState(() {
//         _markers = markers;
//       });
//     }
//   }

//   void _resetMapController() {
//     setState(() {
//       _controller = Completer();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.future.then((controller) => controller.dispose());
//     _farmSubscription.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isConnected = context.watch<ConnectivityService>().isConnected;
//     return Scaffold(
//       body: !isLoading
//           ? isConnected
//               ? gmaps.GoogleMap(
//                   mapType: gmaps.MapType.normal,
//                   markers: _markers,
//                   polygons: _polygons,
//                   myLocationButtonEnabled: false,
//                   zoomControlsEnabled: true,
//                   initialCameraPosition: initialCameraPosition!,
//                   onMapCreated: (gmaps.GoogleMapController controller) {
//                     if (!_controller.isCompleted) {
//                       _controller.complete(controller);
//                     }
//                     _manager.setMapId(controller.mapId);
//                   },
//                   onCameraMove: _manager.onCameraMove,
//                   onCameraIdle: _manager.updateMap,
//                 )
//               : osm.FlutterMap(
//                   options: const osm.MapOptions(
//                     initialCenter: latlng.LatLng(31.992004, 35.879355),
//                     initialZoom: 6,
//                     interactionOptions: osm.InteractionOptions(
//                       flags: ~osm.InteractiveFlag.doubleTapZoom,
//                     ),
//                   ),
//                   children: [
//                     openStreetMapTileLayer,
//                   ],
//                 )
//           : const Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }
// }

// osm.TileLayer get openStreetMapTileLayer => osm.TileLayer(
//       urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//       userAgentPackageName: 'dev.fleaflet.flutter_map.example',
//     );

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:palmear_application/data/repositories/farm_repository.dart';
import 'package:palmear_application/data/repositories/tree_repository.dart';
import 'package:palmear_application/data/services/firestore_services/connectivity_service.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';
import 'package:palmear_application/domain/entities/farm_model.dart';
import 'package:palmear_application/domain/entities/tree_model.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/calculate_centroid.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/marker_builder.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/update_camera_bounds.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late ClusterManager _manager;
  Completer<gmaps.GoogleMapController> _controller = Completer();
  gmaps.CameraPosition? initialCameraPosition;
  bool isLoading = true; // To handle loading state
  bool hasInternet = true;
  List<TreeModel> treesList = [];
  late Set<gmaps.Marker> _markers = {};
  final Set<gmaps.Polygon> _polygons = {};
  List<gmaps.LatLng> _polygonPoints = [];
  late StreamSubscription<List<FarmModel>> _farmSubscription; // Declared here
  late VoidCallback _connectivityListener;

  @override
  void initState() {
    super.initState();
    _setFarmLocations();
    _manager = _initClusterManager();

    _connectivityListener = () {
      if (mounted) {
        bool isConnected = context.read<ConnectivityService>().isConnected;
        setState(() {
          hasInternet = isConnected;
        });
        if (isConnected) {
          _resetMapController();
          _manager = _initClusterManager();
        }
      }
    };

    context.read<ConnectivityService>().addListener(_connectivityListener);
  }

  Future<void> _setFarmLocations() async {
    var sessionUser = UserSession().getUser();
    if (sessionUser != null) {
      var farmRepository = FarmRepository(userId: sessionUser.uid);
      _farmSubscription = farmRepository.getFarmsStream().listen((farms) async {
        List<gmaps.LatLng> updatedPolygonPoints = [];
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
              gmaps.LatLng centroid = calculateCentroid(_polygonPoints);

              initialCameraPosition = gmaps.CameraPosition(
                target: centroid,
                zoom: 6,
              );

              _polygons.clear();
              _polygons.add(gmaps.Polygon(
                polygonId: const gmaps.PolygonId("farmPolygon"),
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
              initialCameraPosition = const gmaps.CameraPosition(
                target: gmaps.LatLng(31.99514837693595, 35.879547964711016),
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

  void _updateMarkers(Set<gmaps.Marker> markers) {
    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _resetMapController() {
    setState(() {
      _controller = Completer();
    });
  }

  @override
  void dispose() {
    _controller.future.then((controller) => controller.dispose());
    _farmSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = context.watch<ConnectivityService>().isConnected;
    return Scaffold(
      body: !isLoading
          ? isConnected
              ? gmaps.GoogleMap(
                  mapType: gmaps.MapType.normal,
                  markers: _markers,
                  polygons: _polygons,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  initialCameraPosition: initialCameraPosition!,
                  onMapCreated: (gmaps.GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                    _manager.setMapId(controller.mapId);
                  },
                  onCameraMove: _manager.onCameraMove,
                  onCameraIdle: _manager.updateMap,
                )
              : osm.FlutterMap(
                  options: osm.MapOptions(
                    initialCenter: _polygonPoints.isNotEmpty
                        ? latlng.LatLng(
                            _polygonPoints.first.latitude,
                            _polygonPoints.first.longitude,
                          )
                        : const latlng.LatLng(31.992004, 35.879355),
                    initialZoom: 6,
                    interactionOptions: const osm.InteractionOptions(
                      flags: ~osm.InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    openStreetMapTileLayer,
                    osm.PolygonLayer(
                      polygons: [
                        osm.Polygon(
                          points: _polygonPoints.map((point) {
                            return latlng.LatLng(
                                point.latitude, point.longitude);
                          }).toList(),
                          color: const Color(0xFF00916E).withOpacity(0.80),
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    osm.MarkerLayer(
                      markers: treesList.map((tree) {
                        return osm.Marker(
                          point: latlng.LatLng(
                              tree.location.latitude, tree.location.longitude),
                          child:
                              const Icon(Icons.location_on, color: Colors.red),
                        );
                      }).toList(),
                    ),
                  ],
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

osm.TileLayer get openStreetMapTileLayer => osm.TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
