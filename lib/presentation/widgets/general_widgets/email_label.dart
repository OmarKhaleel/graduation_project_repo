import 'package:flutter/material.dart';

class EmailLabel extends StatelessWidget {
  const EmailLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Email',
      style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.03,
          fontWeight: FontWeight.bold),
    );
  }
}
