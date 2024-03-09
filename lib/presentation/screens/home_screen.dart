import 'dart:async';
import 'package:flutter/material.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';
import 'package:palmear_application/data/repositories/audio_device_repository.dart';
import 'package:palmear_application/domain/use_cases/get_audio_devices.dart';
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
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_audioDevices.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No audio devices connected',
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: _audioDevices.length,
                itemBuilder: (context, index) {
                  final device = _audioDevices[index];
                  return ListTile(
                    title: Text(device.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sample Rate: ${device.sampleRate} Hz'),
                        Text('Channels: ${device.channels}'),
                        Text('Callback Function: ${device.callbackFunction}'),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            Text(
              'Palmear Audio Amplifier Status: ${isPalmearAudioAmplifierConnected ? 'Connected' : 'Not connected'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Listening time: $countdown seconds',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
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
                    return isListening ? Colors.red : Colors.green;
                  },
                ),
                shape: MaterialStateProperty.all<CircleBorder>(
                  const CircleBorder(),
                ),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Center(
                  child: Text(
                    isListening ? 'Stop' : 'Start',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isListening
                  ? 'Press to stop listening'
                  : 'Press to start listening',
              style: const TextStyle(fontSize: 16),
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
        title: const Text('Pest Detection'),
      ),
      body: _buildPageContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
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
            stopScan();
          } else {
            countdown--;
          }
        });
      },
    );
  }
}
