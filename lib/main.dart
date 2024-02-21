import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pest Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool isListening = false;
  int countdown = 50;
  Timer? timer;
  bool isPalmearAudioAmplifierConnected =
      false; // Initially set to "Not connected"
  Set<String> audioDeviceNames = {};

  @override
  void initState() {
    super.initState();
    _fetchAudioDevices(); // Fetch audio devices on initialization
  }

  Future<void> _fetchAudioDevices() async {
    try {
      final session = await AudioSession.instance;
      final availableDevices = await session.getDevices();
      setState(() {
        audioDeviceNames.clear();
        // Check if the Palmear Audio Amplifier is among the available inputs
        isPalmearAudioAmplifierConnected =
            false; // Reset the flag before checking
        for (var device in availableDevices) {
          audioDeviceNames.add(device.name);
          if (device.name.toLowerCase().contains('palmear')) {
            isPalmearAudioAmplifierConnected = true;
          }
        }
      });
    } catch (e) {
      debugPrint('Error fetching audio devices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pest Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Connected Audio Devices:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: audioDeviceNames.map((deviceName) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    deviceName,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
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
                  // Display popup or alert if Palmear Audio Amplifier is not connected
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
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
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

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }
}
