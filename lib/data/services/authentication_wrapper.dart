import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/domain/use_cases/get_audio_devices.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final audioDeviceRepository = AudioDeviceRepositoryImpl();
    final getAudioDevices = GetAudioDevices(audioDeviceRepository);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return MyHomePage(getAudioDevices: getAudioDevices);
          } else {
            return const SignInScreen();
          }
        }
      },
    );
  }
}
