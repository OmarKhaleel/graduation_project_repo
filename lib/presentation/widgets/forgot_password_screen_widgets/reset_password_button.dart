import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_services/password_reset_service.dart';
import 'package:palmear_application/domain/use_cases/forgot_password_screen_use_cases/get_button_color.dart';

class ResetPasswordButton extends StatelessWidget {
  final TextEditingController emailController;

  const ResetPasswordButton({super.key, required this.emailController});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        passwordReset(context, emailController);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          getButtonColor(emailController),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: const Text('Reset Password'),
    );
  }
}
