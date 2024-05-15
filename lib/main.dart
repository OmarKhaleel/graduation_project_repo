import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/data/services/firestore_services/connectivity_service.dart';
import 'package:palmear_application/data/services/firestore_services/database_helper.dart';
import 'package:palmear_application/data/services/provider_services/audio_device_provider.dart';
import 'package:palmear_application/data/services/provider_services/farm_provider.dart';
import 'package:palmear_application/data/services/audio_services/audio_services.dart';
import 'package:palmear_application/data/services/provider_services/settings_provider.dart';
import 'package:palmear_application/data/services/provider_services/tree_provider.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';
import 'package:palmear_application/theme/app_theme.dart';
import 'package:palmear_application/domain/entities/user_model.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AudioProcessor audioProcessor = AudioProcessor();
  bool hasPermission = await audioProcessor.requestMicrophonePermission();
  debugPrint('Microphone permission granted: $hasPermission');
  UserModel? currentUser =
      await loadCurrentUser(FirebaseAuth.instance.currentUser?.uid);
  runApp(MyApp(currentUser: currentUser));
}

Future<UserModel?> loadCurrentUser(String? uid) async {
  if (uid == null) return null;
  try {
    final dbHelper = DatabaseHelper.instance;
    var userMap = await dbHelper.getUser(uid);
    UserModel userModel = UserModel.fromJson(userMap);
    UserSession().setUser(userModel);
    return userModel;
  } catch (e) {
    debugPrint("Error loading user from local database: $e");
    return null;
  }
}

class MyApp extends StatefulWidget {
  final UserModel? currentUser;

  const MyApp({super.key, this.currentUser});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _connectivityService.initializeConnectivityListener();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AudioDeviceNotifier(AudioDeviceRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(), // Add this provider
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Provider<FarmProvider>(
          create: (_) => FarmProvider(widget.currentUser?.uid ?? ''),
          // child: widget.currentUser == null
          //     ? const SignInScreen()
          //     : const MyHomePage(),
          child: ChangeNotifierProvider(
            create: (_) => FarmProvider(widget.currentUser!.uid),
            child: Consumer<FarmProvider>(
              builder: (context, farmProvider, _) {
                String farmId = farmProvider.farms.isNotEmpty
                    ? farmProvider.farms.first.uid
                    : "specificFarmId"; // Replace with logic to get the first farm or specific ID
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (_) =>
                          TreeProvider(widget.currentUser!.uid, farmId),
                    ),
                  ],
                  child: widget.currentUser == null
                      ? const SignInScreen()
                      : const MyHomePage(),
                );
              },
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
