import 'package:flutter/material.dart';
import 'get_button_color.dart';

ButtonStyle customButtonStyle(bool isListening, int countdown) {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        return isListening ? getButtonColor(countdown) : Colors.white;
      },
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100.0),
      ),
    ),
  );
}
