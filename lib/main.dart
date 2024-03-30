import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/authentication_wrapper.dart';
import 'package:palmear_application/theme/app_theme.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCHL7ISZxboxkAMjJm7ZG-cE6-56Y3NX9w",
            appId: "1:638597228344:web:98fe61b1e85b08a5d7c3cd",
            messagingSenderId: "638597228344",
            projectId: "palmearapplication-1f40c"));
  } else {
    await Firebase.initializeApp();
  }

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
