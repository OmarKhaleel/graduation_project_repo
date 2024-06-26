import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';
import 'package:palmear_application/data/services/firestore_services/database_helper.dart';

Future<void> signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  await UserSession().clearUser();
  await DatabaseHelper.instance.clearUserData();

  if (context.mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }
}
