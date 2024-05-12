import 'package:flutter/material.dart';

class EnterCredentialsText extends StatelessWidget {
  const EnterCredentialsText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Please enter your credentials',
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.03,
          fontWeight: FontWeight.bold),
    );
  }
}
