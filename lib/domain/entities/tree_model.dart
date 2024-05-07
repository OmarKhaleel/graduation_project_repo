import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TreeModel with ClusterItem {
  final String uid;
  final String label;
  @override
  final LatLng location;

  TreeModel({required this.uid, required this.label, required this.location});

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'label': label,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude
      }
    };
  }

  factory TreeModel.fromJson(Map<String, dynamic> json) {
    return TreeModel(
        uid: json['uid'],
        label: json['label'],
        location: LatLng(
            json['location']['latitude'], json['location']['longitude']));
  }
}
