import 'package:firebase_auth/firebase_auth.dart';
import 'package:palmear_application/data/services/firestore_services/database_helper.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:palmear_application/data/services/firestore_services/sync_manager.dart';

class TreeDetails {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SyncManager _syncManager = SyncManager();

  Future<void> addTreeToUserFarm(
      String label, double latitude, double longitude, String farmid) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _dbHelper.addTree(label, latitude, longitude, farmid);
        showToast(message: "Tree added successfully");

        await _syncIfConnected();
      } catch (e) {
        showToast(message: "Error while adding the new tree: $e");
      }
    }
  }

  Future<void> updateSelectedTreeLabel(String treeid, String label) async {
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await _dbHelper.updateTreeLabel(treeid, label);
        showToast(message: "Tree label updated successfully");

        await _syncIfConnected();
      } catch (e) {
        showToast(message: "Error while editing the updated tree label: $e");
      }
    }
  }

  Future<void> _syncIfConnected() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      // ignore: unrelated_type_equality_checks
      bool hasInternet = connectivityResult != ConnectivityResult.none;

      if (hasInternet) {
        await _syncManager.syncTreesToFirestore();
      }
    } catch (e) {
      // Handle errors gracefully if needed
    }
  }
}
