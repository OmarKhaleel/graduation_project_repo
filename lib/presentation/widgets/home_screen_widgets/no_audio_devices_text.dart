import 'package:flutter/material.dart';

class NoAudioDevicesText extends StatelessWidget {
  const NoAudioDevicesText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Text(
        'No audio devices connected',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
