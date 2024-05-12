import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_services/firebase_auth_services.dart';
import 'package:palmear_application/data/services/firebase_services/signin_service.dart';
import 'package:palmear_application/data/services/firestore_services/sync_manager.dart';
import 'package:palmear_application/domain/use_cases/general_use_cases/get_button_color.dart';

class SignInButton extends StatelessWidget {
  final BuildContext context;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FirebaseAuthService auth;
  final SyncManager syncManager;

  const SignInButton({
    super.key,
    required this.context,
    required this.emailController,
    required this.passwordController,
    required this.auth,
    required this.syncManager,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        signIn(
          context,
          emailController.text,
          passwordController.text,
          auth,
          syncManager,
        );
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          getButtonColor(emailController, passwordController),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: const Text('Sign In'),
    );
  }
}
