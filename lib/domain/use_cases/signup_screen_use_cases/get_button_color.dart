import 'package:flutter/material.dart';

Color getButtonColor(TextEditingController emailController,
    TextEditingController passwordController, bool agreeToTerms) {
  if (emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty &&
      agreeToTerms) {
    return const Color(0xFF00916E);
  } else {
    return const Color(0xFF66BEA8);
  }
}
