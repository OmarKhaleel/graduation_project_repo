import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class SyncManager {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncFromFirestore(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userMap = userDoc.data() as Map<String, dynamic>;
        userMap['uid'] = userDoc.id;
        userMap['isModified'] = 0;
        await _dbHelper.insertOrUpdateUser(userMap);

        var farmCollection = userDoc.reference.collection('farms');
        var farmSnapshot = await farmCollection.get();
        for (var farmDoc in farmSnapshot.docs) {
          Map<String, dynamic> farmMap = farmDoc.data();
          farmMap['uid'] = farmDoc.id;
          farmMap['user_id'] = userId;
          farmMap['isModified'] = 0;
          if (farmMap.containsKey('locations') &&
              farmMap['locations'] != null) {
            farmMap['locations'] =
                _convertGeoPointsToString(farmMap['locations']);
          }
          await _dbHelper.insertOrUpdateFarm(farmMap);

          var treeCollection = farmDoc.reference.collection('trees');
          var treeSnapshot = await treeCollection.get();
          for (var treeDoc in treeSnapshot.docs) {
            Map<String, dynamic> treeMap = treeDoc.data();
            treeMap['uid'] = treeDoc.id;
            treeMap['farm_id'] = farmDoc.id;
            treeMap['isModified'] = 0;
            if (treeMap.containsKey('location')) {
              var location = treeMap['location'];
              treeMap['latitude'] = location['latitude'];
              treeMap['longitude'] = location['longitude'];
              treeMap.remove('location'); // Remove the location map entry
            }
            await _dbHelper.insertOrUpdateTree(treeMap);
          }
        }
      }
    } catch (e) {
      showToast(message: "Error syncing from Firestore: $e");
    }
  }

  Future<void> syncToFirestore() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      // ignore: unrelated_type_equality_checks
      if (connectivityResult == ConnectivityResult.none) {
        return; // No internet connection, skip sync
      }

      await syncUsersToFirestore();
      await syncFarmsToFirestore();
      await syncTreesToFirestore();
    } catch (e) {
      showToast(message: "Error syncing to Firestore: $e");
    }
  }

  String _convertGeoPointsToString(List<dynamic> locations) {
    return locations.map((point) {
      GeoPoint gp = point as GeoPoint;
      return "${gp.latitude},${gp.longitude}";
    }).join(';');
  }

  Future<void> syncUsersToFirestore() async {
    var localUsers = await _dbHelper.getModified("users");
    for (var user in localUsers) {
      var userRef = _firestore.collection('users').doc(user['uid'] as String);
      var userData = Map<String, dynamic>.from(user)
        ..removeWhere((key, value) => key == 'isModified' || key == 'id');
      await userRef.set(userData, SetOptions(merge: true));
      await _dbHelper.markAsUnmodified("users", user['uid'] as String);
    }
  }

  Future<void> syncFarmsToFirestore() async {
    var localFarms = await _dbHelper.getModified("farms");
    for (var farm in localFarms) {
      var userRef =
          _firestore.collection('users').doc(farm['user_id'] as String);
      var farmRef = userRef.collection('farms').doc(farm['uid'] as String);
      var farmData = Map<String, dynamic>.from(farm)
        ..removeWhere((key, value) => key == 'isModified' || key == 'id');
      if (farmData.containsKey('locations') &&
          farmData['locations'] is String) {
        farmData['locations'] =
            _convertStringToGeoPoints(farmData['locations'] as String);
      }
      await farmRef.set(farmData, SetOptions(merge: true));
      await _dbHelper.markAsUnmodified("farms", farm['uid'] as String);
    }
  }

  Future<void> syncTreesToFirestore() async {
    try {
      var localTrees = await _dbHelper.getModified("trees");
      for (var tree in localTrees) {
        var farm = await _dbHelper.getFarm(tree['farm_id']);
        if (farm != null) {
          var userRef =
              _firestore.collection('users').doc(farm['user_id'] as String);
          var farmRef =
              userRef.collection('farms').doc(tree['farm_id'] as String);
          var treeRef = farmRef.collection('trees').doc(tree['uid'] as String);

          var snapshot = await treeRef.get();
          Map<String, dynamic> locationMap = {
            'latitude': tree['latitude'],
            'longitude': tree['longitude']
          };

          if (snapshot.exists) {
            var treeData = {'label': tree['label']};
            await treeRef.update(treeData);
            debugPrint("Updated tree label for: ${tree['uid']}");
          } else {
            var treeData = Map<String, dynamic>.from(tree)
              ..removeWhere((key, value) =>
                  key == 'isModified' ||
                  key == 'id' ||
                  key == 'latitude' ||
                  key == 'longitude' ||
                  key == 'farm_id')
              ..['location'] = locationMap;
            await treeRef.set(treeData);
            debugPrint("Added new tree: ${tree['uid']}");
          }
          await _dbHelper.markAsUnmodified("trees", tree['uid'] as String);
        } else {
          showToast(message: "No matching farm found for tree: ${tree['uid']}");
        }
      }
    } catch (e) {
      debugPrint("Error syncing trees to Firestore: $e");
      debugPrint("Error syncing trees to Firestore: $e");
    }
  }

  List<GeoPoint> _convertStringToGeoPoints(String locations) {
    return locations.split(';').map((s) {
      var latLng = s.split(',');
      return GeoPoint(double.parse(latLng[0]), double.parse(latLng[1]));
    }).toList();
  }
}
