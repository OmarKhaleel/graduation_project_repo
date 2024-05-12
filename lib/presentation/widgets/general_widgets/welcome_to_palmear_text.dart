import 'package:flutter/material.dart';

class WelcomeToPalmearText extends StatelessWidget {
  const WelcomeToPalmearText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Welcome to Palmear',
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.05,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }
}
