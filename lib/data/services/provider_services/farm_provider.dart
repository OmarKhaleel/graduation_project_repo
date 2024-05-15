import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palmear_application/domain/entities/farm_model.dart';

class FarmProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<FarmModel> _farms = [];

  List<FarmModel> get farms => _farms;

  FarmProvider(String userId) {
    _fetchFarms(userId);
  }

  void _fetchFarms(String userId) {
    _firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .snapshots()
        .listen((snapshot) {
      _farms = snapshot.docs.map((doc) {
        var data = doc.data();
        return FarmModel.fromJson(data);
      }).toList();
      notifyListeners();
    });
  }

  Future<void> updateFarmGeopoints(
      String userId, String farmId, List<GeoPoint> newGeopoints) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .doc(farmId)
        .update({
      'locations': newGeopoints
          .map((point) =>
              {'latitude': point.latitude, 'longitude': point.longitude})
          .toList()
    });
  }
}
