import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_services/firebase_auth_services.dart';
import 'package:palmear_application/data/services/firestore_services/sync_manager.dart';
import 'package:palmear_application/domain/entities/user_model.dart';
import 'package:palmear_application/data/repositories/user_repository.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> signIn(BuildContext context, String email, String password,
    FirebaseAuthService auth, SyncManager syncManager) async {
  if (email.isEmpty || password.isEmpty) {
    showToast(message: "Email or password cannot be empty.");
    return;
  }

  try {
    User? user =
        await auth.signInWithEmailAndPassword(email, password) as User?;

    if (user != null) {
      UserRepository userRepository = UserRepository();
      UserModel? userModel = await userRepository.getUser(user.uid);

      if (userModel != null) {
        // Set user in the singleton UserSession
        UserSession().setUser(userModel);
        await syncManager.syncFromFirestore(user.uid);
        showToast(message: "User is successfully signed in!");

        // Proceed to navigate to the home screen
        if (context.mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const MyHomePage()));
        }
      } else {
        showToast(message: "Failed to retrieve user data.");
      }
    } else {
      showToast(message: "Failed to sign in.");
    }
  } catch (e) {
    showToast(message: "Error signing in: $e");
  }
}
