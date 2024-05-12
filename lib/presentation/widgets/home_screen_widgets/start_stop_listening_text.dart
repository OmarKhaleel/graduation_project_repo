import 'package:flutter/material.dart';

class StartStopListeningText extends StatelessWidget {
  final bool isListening;

  const StartStopListeningText({super.key, required this.isListening});

  @override
  Widget build(BuildContext context) {
    return Text(
      isListening ? 'Press to stop listening' : 'Press to start listening',
      style: const TextStyle(fontSize: 16, color: Colors.white),
    );
  }
}
