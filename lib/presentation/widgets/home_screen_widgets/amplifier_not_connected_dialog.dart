import 'package:flutter/material.dart';

class AmplifierNotConnectedDialog extends StatelessWidget {
  const AmplifierNotConnectedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Palmear Audio Amplifier Not Connected'),
      content: const Text(
          'Please connect the Palmear Audio Amplifier properly to the mobile phone.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
