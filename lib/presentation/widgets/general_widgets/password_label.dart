import 'package:flutter/material.dart';

class PasswordLabel extends StatelessWidget {
  const PasswordLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Password',
      style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.03,
          fontWeight: FontWeight.bold),
    );
  }
}
