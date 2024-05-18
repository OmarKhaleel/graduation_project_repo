import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firestore_services/database_helper.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';
import 'package:palmear_application/domain/entities/user_model.dart';

Future<UserModel?> loadCurrentUser(String? uid) async {
  if (uid == null) return null;
  try {
    final dbHelper = DatabaseHelper.instance;
    var userMap = await dbHelper.getUser(uid);
    UserModel userModel = UserModel.fromJson(userMap);
    UserSession().setUser(userModel);
    return userModel;
  } catch (e) {
    debugPrint("Error loading user from local database: $e");
    return null;
  }
}
