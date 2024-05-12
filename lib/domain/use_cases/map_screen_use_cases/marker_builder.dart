import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:palmear_application/domain/entities/tree_model.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/center_and_zoom_in.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/marker_bitmap.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/pie_chart_marker_bitmap.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/zoom_into_cluster.dart';

Future<Marker> Function(Cluster<TreeModel>) markerBuilder(
        Completer<GoogleMapController> controller) =>
    (cluster) async {
      if (cluster.isMultiple) {
        int greenCount = 0;
        int redCount = 0;
        for (var item in cluster.items) {
          if (item.label == "Healthy") {
            greenCount++;
          } else if (item.label == "Infested") {
            redCount++;
          }
        }
        int totalCount = cluster.count;
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          icon: await getPieChartMarkerBitmap(
              125, greenCount, redCount, totalCount),
          onTap: () => zoomIntoCluster(cluster.location, controller),
        );
      } else {
        // Handle individual tree marker
        Color markerColor = Colors.orange; // Default color
        String label = cluster.items.first.label;
        if (label == "Healthy") {
          markerColor = Colors.green;
        } else if (label == "Infested") {
          markerColor = Colors.red;
        }
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          icon: await getMarkerBitmap(75, color: markerColor),
          onTap: () => centerAndZoomIn(cluster.location, controller),
        );
      }
    };
