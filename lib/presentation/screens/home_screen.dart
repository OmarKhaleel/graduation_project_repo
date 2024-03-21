import 'dart:async';
import 'package:flutter/material.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';
import 'package:palmear_application/data/repositories/audio_device_repository.dart';
import 'package:palmear_application/domain/use_cases/get_audio_devices.dart';
import 'package:palmear_application/presentation/widgets/bottom_navigation_bar.dart';
import 'map_screen.dart';
import 'settings_screen.dart';

class MyHomePage extends StatefulWidget {
  final GetAudioDevices getAudioDevices;

  const MyHomePage({super.key, required this.getAudioDevices});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool isListening = false;
  int countdown = 50;
  Timer? timer;
  bool isPalmearAudioAmplifierConnected = false;
  List<AudioDeviceInfo> _audioDevices = [];

  final audioDeviceRepository = AudioDeviceRepository();

  @override
  void initState() {
    super.initState();
    _getAudioDevices();
  }

  Future<void> _getAudioDevices() async {
    try {
      final devices = await audioDeviceRepository.getAudioDevices();
      final deviceMap = <String, AudioDeviceInfo>{};

      for (final device in devices) {
        if (!deviceMap.containsKey(device.name) ||
            device.sampleRate > deviceMap[device.name]!.sampleRate) {
          deviceMap[device.name] = device;
        }
      }

      setState(() {
        _audioDevices = deviceMap.values.toList();
        isPalmearAudioAmplifierConnected = _audioDevices
            .any((device) => device.name.toLowerCase().contains('palmear'));
      });
    } catch (e) {
      debugPrint("Failed to get audio devices: '$e'.");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const MapScreen();
      case 2:
        return const SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_audioDevices.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.1),
                child: Text(
                  'No audio devices connected',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      color: Colors.white),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: _audioDevices.length,
                itemBuilder: (context, index) {
                  final device = _audioDevices[index];
                  return ListTile(
                    title: Text(
                      device.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sample Rate: ${device.sampleRate} Hz',
                            style: const TextStyle(color: Colors.white)),
                        Text('Channels: ${device.channels}',
                            style: const TextStyle(color: Colors.white)),
                        Text('Callback Function: ${device.callbackFunction}',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                },
              ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.02),
            Text(
              'Palmear Audio Amplifier Status: ${isPalmearAudioAmplifierConnected ? 'Connected' : 'Not connected'}',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  color: Colors.white),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.15),
            Text(
              'Listening time: $countdown seconds',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.041,
                  color: Colors.white),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.03),
            ElevatedButton(
              onPressed: () {
                if (!isPalmearAudioAmplifierConnected) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title:
                            const Text('Palmear Audio Amplifier Not Connected'),
                        content: const Text(
                          'Please connect the Palmear Audio Amplifier properly to the mobile phone.',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  setState(() {
                    isListening = !isListening;
                    countdown = 50;
                    if (isListening) {
                      startCountdown();
                      startScan();
                    } else {
                      stopScan();
                      timer?.cancel();
                    }
                  });
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return isListening ? Colors.red : Colors.white;
                  },
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
                padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.15)),
              ),
              child: Icon(
                Icons.hearing,
                size: MediaQuery.of(context).size.width * 0.2,
                color: const Color(0xFF00916E),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.02),
            Text(
              isListening
                  ? 'Press to stop listening'
                  : 'Press to start listening',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Pest Detection', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00916E),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Implement action
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF00916E),
      body: _buildPageContent(),
      bottomNavigationBar: BottomNavigationBarScreen(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startScan() {
    debugPrint('Listening...');
  }

  void stopScan() {
    debugPrint('Stopped listening');
  }

  void startCountdown() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          if (countdown < 1) {
            timer.cancel();
            isListening = false;
            countdown = 50;
            stopScan();
          } else {
            countdown--;
          }
        });
      },
    );
  }
}
