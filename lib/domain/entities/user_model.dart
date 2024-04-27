import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final List<LatLng> locations;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.locations,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'locations': locations
          .map((latLng) => GeoPoint(latLng.latitude, latLng.longitude))
          .toList(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var locationsList = json['locations'] as List;
    List<LatLng> locations = locationsList.map((location) {
      GeoPoint geoPoint = location as GeoPoint;
      return LatLng(geoPoint.latitude, geoPoint.longitude);
    }).toList();

    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      locations: locations,
    );
  }
}
