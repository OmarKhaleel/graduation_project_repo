import 'package:flutter/material.dart';
import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/domain/use_cases/get_audio_devices.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final audioDeviceRepository = AudioDeviceRepositoryImpl();
    final getAudioDevices = GetAudioDevices(audioDeviceRepository);

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(getAudioDevices: getAudioDevices),
      debugShowCheckedModeBanner: false,
    );
  }
}
