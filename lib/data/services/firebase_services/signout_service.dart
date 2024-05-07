import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:palmear_application/data/services/user_session/user_session.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';

Future<void> signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  await UserSession().clearUser();

  // Only navigate if the context is still mounted
  if (context.mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }
}
