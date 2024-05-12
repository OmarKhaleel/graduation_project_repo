import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palmear_application/data/services/firestore_services/database_helper.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UserDetails {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

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
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'name': newName});
        await _dbHelper.markAsUnmodified('users', user.uid);
      }
      return true;
    } catch (e) {
      showToast(message: "Error updating name: $e");
      return false;
    }
  }
}
