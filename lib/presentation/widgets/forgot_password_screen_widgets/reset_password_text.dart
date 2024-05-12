import 'package:flutter/material.dart';

class ResetPasswordText extends StatelessWidget {
  const ResetPasswordText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Reset Password',
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.05,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }
}
