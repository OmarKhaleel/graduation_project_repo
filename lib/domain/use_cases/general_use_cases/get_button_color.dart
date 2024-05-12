import 'package:flutter/material.dart';

Color getButtonColor(TextEditingController emailController,
    TextEditingController passwordController) {
  if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
    return const Color(0xFF00916E);
  } else {
    return const Color(0xFF66BEA8);
  }
}
