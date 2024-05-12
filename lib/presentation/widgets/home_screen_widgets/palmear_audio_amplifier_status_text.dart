import 'package:flutter/material.dart';

class PalmearAudioAmplifierStatusText extends StatelessWidget {
  final bool isPalmearAudioAmplifierConnected;

  const PalmearAudioAmplifierStatusText(
      {super.key, required this.isPalmearAudioAmplifierConnected});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Palmear Audio Amplifier Status: ${isPalmearAudioAmplifierConnected ? 'Connected' : 'Not connected'}',
      style: const TextStyle(fontSize: 16, color: Colors.white),
    );
  }
}
