import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:palmear_application/data/services/audio_services/audio_services.dart';
import 'package:palmear_application/domain/use_cases/main_use_cases/load_current_user.dart';
import 'package:palmear_application/presentation/widgets/main_widgets/main_widgets_provider.dart';
import 'package:palmear_application/domain/entities/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMain();
  }

  void _navigateToMain() async {
    AudioProcessor audioProcessor = AudioProcessor();
    bool hasPermission = await audioProcessor.requestMicrophonePermission();
    debugPrint('Microphone permission granted: $hasPermission');
    UserModel? currentUser =
        await loadCurrentUser(FirebaseAuth.instance.currentUser?.uid);

    await Future.delayed(
      const Duration(seconds: 2),
    ); // Adjust the delay as needed

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => MainWidgetsProvider(currentUser: currentUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/palmear_logo.png'),
        ),
      ),
    );
  }
}
