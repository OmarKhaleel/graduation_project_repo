import 'package:flutter/material.dart';

class EnterYourEmailText extends StatelessWidget {
  const EnterYourEmailText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Please enter your email to reset your password',
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.03,
          fontWeight: FontWeight.bold),
    );
  }
}
