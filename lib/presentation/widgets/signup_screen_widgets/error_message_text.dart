import 'package:flutter/material.dart';

class ErrorMessageText extends StatelessWidget {
  final String errorMessage;

  const ErrorMessageText({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        errorMessage,
        style: const TextStyle(
            color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
      ), // Display the error message
    );
  }
}
