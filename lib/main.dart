import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firestore_services/connectivity_service.dart';
import 'package:palmear_application/presentation/screens/splash_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
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
  late ConnectivityService _connecitvityService;

  @override
  void initState() {
    super.initState();
    _connecitvityService = ConnectivityService();
    _connecitvityService.initializeConnectivityListener();
  }

  @override
  void dispose() {
    _connecitvityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ConnectivityService(),
          ),
        ],
        child: const MaterialApp(
          home: SplashScreen(),
          debugShowCheckedModeBanner: false,
        ));
  }
}
