import 'package:flutter/material.dart';

Color getButtonColor(int countdown) {
  if (countdown > 30) {
    return Colors.green;
  } else if (countdown > 10) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}
