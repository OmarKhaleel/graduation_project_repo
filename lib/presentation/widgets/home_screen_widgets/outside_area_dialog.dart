import 'package:flutter/material.dart';

class OutsideAreaDialog extends StatelessWidget {
  const OutsideAreaDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Out of your authorized area!'),
      content: const Text(
          'You can\'t scan trees that aren\'t inside your farm. Please make sure you\'re inside your farm to be able to scan.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
