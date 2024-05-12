import 'package:flutter/material.dart';

Color getButtonColor(TextEditingController emailController) {
  if (emailController.text.isNotEmpty) {
    return const Color(0xFF00916E);
  } else {
    return const Color(0xFF66BEA8);
  }
}
