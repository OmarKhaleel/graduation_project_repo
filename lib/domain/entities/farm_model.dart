import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FarmModel {
  final String uid;
  final String name;
  final List<LatLng> locations;
  FarmModel({
    required this.uid,
    required this.name,
    required this.locations,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'locations': locations
          .map((latLng) => GeoPoint(latLng.latitude, latLng.longitude))
          .toList(),
    };
  }

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    var locationsList = json['locations'] as List;
    List<LatLng> locations = locationsList.map((location) {
      GeoPoint geoPoint = location as GeoPoint;
      return LatLng(geoPoint.latitude, geoPoint.longitude);
    }).toList();
    return FarmModel(
      uid: json['uid'],
      name: json['name'],
      locations: locations,
    );
  }
}
