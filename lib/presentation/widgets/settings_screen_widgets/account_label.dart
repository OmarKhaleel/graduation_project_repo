import 'package:flutter/material.dart';

class AccountLabel extends StatelessWidget {
  const AccountLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 16.0, top: 28.0, bottom: 8.0),
      child: Text(
        "ACCOUNT",
        style: TextStyle(color: Color(0xFFB0AFB0), fontWeight: FontWeight.bold),
      ),
    );
  }
}
