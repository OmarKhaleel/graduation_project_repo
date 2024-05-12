import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_services/firebase_auth_services.dart';
import 'package:palmear_application/data/services/firebase_services/signup_service.dart';
import 'package:palmear_application/domain/use_cases/signup_screen_use_cases/get_button_color.dart';

class SignUpButton extends StatelessWidget {
  final BuildContext context;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool agreeToTerms;
  final FirebaseAuthService auth;
  final Function(String) setErrorMessage;

  const SignUpButton(
      {super.key,
      required this.context,
      required this.emailController,
      required this.passwordController,
      required this.agreeToTerms,
      required this.auth,
      required this.setErrorMessage});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        signUp(
            context,
            emailController.text.trim(),
            passwordController.text.trim(),
            agreeToTerms,
            auth,
            setErrorMessage);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          getButtonColor(emailController, passwordController, agreeToTerms),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: const Text('Sign Up'),
    );
  }
}
