import 'package:flutter/material.dart';

class AppVersionListTile extends StatelessWidget {
  const AppVersionListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      tileColor: Colors.white,
      title: Text('0.0.9 (Prototype)'),
      textColor: Colors.black,
    );
  }
}
