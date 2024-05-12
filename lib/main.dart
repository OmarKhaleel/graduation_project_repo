import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_services/authentication_wrapper.dart';
import 'package:palmear_application/data/services/firestore_services/connectivity_service.dart';
import 'package:palmear_application/data/services/firestore_services/farm_provider.dart';
import 'package:palmear_application/theme/app_theme.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _connectivityService.initializeConnectivityListener();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data != null) {
              // User is signed in
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => FarmProvider(snapshot.data!.uid),
                  ),
                ],
                child: const AuthenticationWrapper(),
              );
            } else {
              // User is not signed in, handle accordingly
              return const AuthenticationWrapper();
            }
          }
          return const CircularProgressIndicator(); // Show loading screen while waiting for authentication
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
