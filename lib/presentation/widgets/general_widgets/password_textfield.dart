import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const PasswordTextField(
      {super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('password_field'),
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00916E)),
        ),
        hintText: 'Enter your password',
      ),
      controller: controller,
      obscureText: true,
      onChanged: onChanged,
    );
  }
}
