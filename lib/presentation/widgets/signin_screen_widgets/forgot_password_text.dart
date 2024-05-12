import 'package:flutter/material.dart';
import 'package:palmear_application/presentation/screens/forgot_password_screen.dart';

class ForgotPasswordText extends StatelessWidget {
  const ForgotPasswordText({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ForgotPasswordScreen()));
      },
      child: const Text(
        'Forgot Password?',
        textAlign: TextAlign.end,
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF00916E),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
