import 'package:flutter/material.dart';

class CountdownText extends StatelessWidget {
  final int countdown;

  const CountdownText({super.key, required this.countdown});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Listening time: $countdown seconds',
      style: const TextStyle(fontSize: 16, color: Colors.white),
    );
  }
}
