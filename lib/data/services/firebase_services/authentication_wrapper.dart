import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:palmear_application/data/services/firestore_services/database_helper.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';
import 'package:palmear_application/domain/entities/user_model.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return FutureBuilder<UserModel?>(
              future: _loadUserFromLocal(snapshot.data!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null) {
                    return const MyHomePage();
                  } else {
                    return const SignInScreen();
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          } else {
            return const SignInScreen();
          }
        }
      },
    );
  }

  Future<UserModel?> _loadUserFromLocal(String uid) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      var userMap = await dbHelper.getUser(uid);
      UserModel userModel = UserModel.fromJson(userMap);
      UserSession().setUser(userModel);
      return userModel;
    } catch (e) {
      // Only log the error to the console instead of showing a toast
      debugPrint("Error loading user from local database: $e");
      return null;
    }
  }
}
