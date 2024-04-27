import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_services/authentication_wrapper.dart';
import 'package:palmear_application/theme/app_theme.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme(),
      home: const AuthenticationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
