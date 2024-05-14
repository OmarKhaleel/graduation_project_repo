import 'package:firebase_auth/firebase_auth.dart';
import 'package:palmear_application/data/services/firestore_services/database_helper.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:palmear_application/data/services/firestore_services/sync_manager.dart';

class UserDetails {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SyncManager _syncManager = SyncManager();

  Future<String> fetchUserName() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        var localUser = await _dbHelper.getUser(user.uid);
        return localUser['name'] as String;
      } catch (e) {
        showToast(message: "Error fetching local user name: $e");
      }
    }
    return 'User';
  }

  Future<bool> updateUserName(String newName) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      // ignore: unrelated_type_equality_checks
      bool hasInternet = connectivityResult != ConnectivityResult.none;

      Map<String, dynamic> updateData = {
        'uid': user.uid,
        'name': newName,
        'isModified': 1
      };
      await _dbHelper.updateUser(updateData);

      if (hasInternet) {
        await _syncManager.syncUsersToFirestore();
      }
      return true;
    } catch (e) {
      showToast(message: "Error updating name: $e");
      return false;
    }
  }
}
