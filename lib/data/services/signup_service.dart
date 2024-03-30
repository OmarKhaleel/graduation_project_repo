import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_auth_services.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';
import 'package:palmear_application/presentation/widgets/toast.dart';

void signUp(BuildContext context, String email, String password,
    bool agreeToTerms, FirebaseAuthService auth) {
  if (email.isNotEmpty && password.isNotEmpty && agreeToTerms) {
    auth.signUpWithEmailAndPassword(email, password);

    try {
      showToast(message: "User is successfully created");
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SignInScreen()));
    } catch (e) {
      showToast(message: "Error signing up: $e");
    }
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Up Error'),
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
