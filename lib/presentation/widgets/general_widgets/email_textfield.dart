import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const EmailTextField(
      {super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('email_field'),
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00916E)),
        ),
        hintText: 'Enter your email',
      ),
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
    );
  }
}
