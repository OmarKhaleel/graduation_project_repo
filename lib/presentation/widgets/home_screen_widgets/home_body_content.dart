import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:palmear_application/data/services/home_screen_services/audio_devices_service.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/countdown_controller.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/scan_utils.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/audio_devices_list_view.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/countdown_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/no_audio_devices_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/palmear_audio_amplifier_status_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/scan_button.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/start_stop_listening_text.dart';

class HomeBodyContent extends StatefulWidget {
  const HomeBodyContent({super.key});

  @override
  State<HomeBodyContent> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeBodyContent> {
  List<AudioDeviceInfo> _audioDevices = [];
  bool isPalmearAudioAmplifierConnected = false;
  bool _isListening = false;
  int _countdown = 50;
  Timer? timer;
  CountdownController? _countdownController;
  bool isTesting = Platform.environment.containsKey('FLUTTER_TEST');

  // Test for live location
  String result = "";
  String lat = "";
  String lng = "";

  @override
  void initState() {
    super.initState();
    _fetchAndUpdateAudioDevices();
    _countdownController = CountdownController(
      onCountdownChanged: (newCount) => setState(() => _countdown = newCount),
      onCountdownCompleted: () async {
        setState(() {
          _isListening = false;
          _countdown = 50;
          stopScan();
        });
        await getUserLocation(); // Fetch and update location after stopping the scan
      },
      initialCountdown: 50,
    );
  }

  Future<void> _fetchAndUpdateAudioDevices() async {
    final devices = await getAudioDevices(isTesting: isTesting);
    setState(() {
      _audioDevices = devices;
      isPalmearAudioAmplifierConnected = _audioDevices
          .any((device) => device.name.toLowerCase().contains('palmear'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_audioDevices.isEmpty)
              const NoAudioDevicesText()
            else
              AudioDevicesListView(audioDevices: _audioDevices),
            const SizedBox(height: 10),
            PalmearAudioAmplifierStatusText(
                isPalmearAudioAmplifierConnected:
                    isPalmearAudioAmplifierConnected),
            const SizedBox(height: 100),
            CountdownText(countdown: _countdown),
            const SizedBox(height: 20),
            ScanButton(
              isListening: _isListening,
              isPalmearAudioAmplifierConnected:
                  isPalmearAudioAmplifierConnected,
              onStartListening: () {
                setState(() {
                  _isListening = true;
                  _countdownController!.startCountdown(_countdown);
                  startScan();
                });
              },
              onStopListening: () {
                setState(() {
                  _countdownController!.resetAndStopCountdown();
                });
              },
              onShowErrorDialog: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title:
                          const Text('Palmear Audio Amplifier Not Connected'),
                      content: const Text(
                          'Please connect the Palmear Audio Amplifier properly to the mobile phone.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            StartStopListeningText(isListening: _isListening),
          ],
        ),
      ),
    );
  }

  //check if location permission is enable
  Future<bool> checkPermission() async {
    bool isEnable = false;
    LocationPermission permission;

    //check if location is enable
    isEnable = await Geolocator.isLocationServiceEnabled();
    if (!isEnable) {
      return false;
    }

    //check if use allow location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // if permission is denied then request user to allow permission again
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // if permission denied again
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

//get user current location
  getUserLocation() async {
    debugPrint("Fetching location...");
    var isEnable = await checkPermission();
    if (isEnable) {
      Position location = await Geolocator.getCurrentPosition();
      setState(() {
        result = "Location fetched successfully";
        lat = location.latitude.toString();
        lng = location.longitude.toString();
        debugPrint("Location: Lat: $lat, Lng: $lng");
      });
    } else {
      setState(() {
        result = "Permissoin is not allowed";
        debugPrint("Location permission denied");
      });
    }
  }

  Widget displayLocation() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          result,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          lat,
          style: const TextStyle(fontSize: 30),
        ),
        Text(
          lng,
          style: const TextStyle(fontSize: 30),
        ),
      ],
    );
  }
}
