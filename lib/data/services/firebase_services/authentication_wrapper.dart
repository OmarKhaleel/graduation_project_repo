import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:palmear_application/data/services/firestore_services/database_helper.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';
import 'package:palmear_application/domain/entities/user_model.dart';
import 'package:palmear_application/data/services/provider_services/farm_provider.dart';
import 'package:provider/provider.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          // Load user model and initiate session
          return FutureBuilder<UserModel?>(
            future: _loadUserFromLocal(snapshot.data!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  return Provider<FarmProvider>(
                    create: (_) => FarmProvider(snapshot.data!.uid),
                    child: const MyHomePage(),
                  );
                } else {
                  return const SignInScreen();
                }
              }
              return const CircularProgressIndicator();
            },
          );
        }
        return const CircularProgressIndicator();
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
      debugPrint("Error loading user from local database: $e");
      return null;
    }
  }
}
