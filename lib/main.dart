import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/audio_services/audio_services.dart';
import 'package:palmear_application/domain/use_cases/main_use_cases/load_current_user.dart';
import 'package:palmear_application/presentation/widgets/main_widgets/main_widgets_provider.dart';
import 'package:palmear_application/domain/entities/user_model.dart';

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

class MyApp extends StatefulWidget {
  final UserModel? currentUser;

  const MyApp({super.key, this.currentUser});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MainWidgetsProvider(currentUser: widget.currentUser);
  }
}
