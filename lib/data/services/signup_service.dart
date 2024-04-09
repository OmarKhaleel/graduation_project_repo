import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_auth_services.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';

void signUp(
    BuildContext context,
    String email,
    String password,
    bool agreeToTerms,
    FirebaseAuthService auth,
    Function(String) setErrorMessage) {
  final emailRegex = RegExp(
      r'^[a-zA-Z][a-zA-Z0-9._]{7,63}@(gmail|hotmail|outlook|yahoo)\.(com|net|org)$');
  final passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');

  // Check if the email and password are not empty
  if (email.isEmpty || password.isEmpty) {
    setErrorMessage("Email or password cannot be empty.");
    return;
  }

  // Initialize an empty error message
  String errorMessage = '';

  // Check if the email and password are valid
  if (!emailRegex.hasMatch(email)) {
    errorMessage += "Email doesn't meet the requirements. ";
  }
  if (!passwordRegex.hasMatch(password)) {
    errorMessage += "Password does not meet requirements. ";
  }

  // If there's an error, set the error message via the callback and return early
  if (errorMessage.isNotEmpty) {
    setErrorMessage(errorMessage.trim());
    return;
  }

  // Check if the terms are agreed
  if (!agreeToTerms) {
    setErrorMessage("You must agree to the terms and conditions to proceed.");
    return;
  }

  // Attempt to sign up the user
  try {
    auth.signUpWithEmailAndPassword(email, password);
    // Success: Navigate to SignInScreen or reset the form
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SignInScreen()));
  } catch (e) {
    // On error: set the error message via the callback
    setErrorMessage("Error signing up: $e");
  }
}
