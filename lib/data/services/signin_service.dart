import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_auth_services.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';
import 'package:palmear_application/presentation/widgets/toast.dart';

void signIn(BuildContext context, String email, String password,
    FirebaseAuthService auth) {
  if (email.isNotEmpty && password.isNotEmpty) {
    auth.signInWithEmailAndPassword(email, password);

    try {
      showToast(message: "User is successfully signed in!");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } catch (e) {
      showToast(message: "Error signing in: $e");
    }
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign In Error'),
          content: const Text('Empty email or password'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
