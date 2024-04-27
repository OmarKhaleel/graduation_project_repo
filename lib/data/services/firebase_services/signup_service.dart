import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:palmear_application/data/services/firebase_services/firebase_auth_services.dart';
import 'package:palmear_application/domain/entities/user_model.dart';
import 'package:palmear_application/data/repositories/user_repository.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';

Future<void> signUp(
    BuildContext context,
    String email,
    String password,
    bool agreeToTerms,
    FirebaseAuthService auth,
    Function(String) setErrorMessage) async {
  final emailRegex = RegExp(
      r'^[a-zA-Z][a-zA-Z0-9._]{7,63}@(gmail|hotmail|outlook|yahoo)\.(com|net|org)$');
  final passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');

  if (email.isEmpty || password.isEmpty) {
    setErrorMessage("Email or password cannot be empty.");
    return;
  }

  if (!emailRegex.hasMatch(email) || !passwordRegex.hasMatch(password)) {
    setErrorMessage("Email or password does not meet requirements.");
    return;
  }

  if (!agreeToTerms) {
    setErrorMessage("You must agree to the terms and conditions to proceed.");
    return;
  }

  try {
    User? user = await auth.signUpWithEmailAndPassword(email, password);
    if (user != null) {
      List<LatLng> locations = [
        const LatLng(31.991549, 35.878889),
        const LatLng(31.991896, 35.878791),
        const LatLng(31.992410, 35.878612),
        const LatLng(31.992539, 35.879559),
        const LatLng(31.992355, 35.879608),
        const LatLng(31.992171, 35.879646),
        const LatLng(31.992011, 35.879732),
        const LatLng(31.991850, 35.879830),
      ];
      UserModel newUser = UserModel(
          uid: user.uid, email: email, locations: locations, name: '');

      await UserRepository().addUser(newUser);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SignInScreen()));
    } else {
      setErrorMessage("Registration failed. No user data available.");
    }
  } catch (e) {
    setErrorMessage("Error signing up: $e");
  }
}
