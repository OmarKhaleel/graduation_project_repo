import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pest Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          if (device != null && device.name != null) {
            audioDeviceNames.add(device.name!);
            if (device.name!.toLowerCase().contains('palmear')) {
              isPalmearAudioAmplifierConnected = true;
            }
          }
        }
      });
    } catch (e) {
      print('Error fetching audio devices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pest Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Connected Audio Devices:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: audioDeviceNames.map((deviceName) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    deviceName,
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Palmear Audio Amplifier Status: ${isPalmearAudioAmplifierConnected ? 'Connected' : 'Not connected'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Listening time: $countdown seconds',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!isPalmearAudioAmplifierConnected) {
                  // Display popup or alert if Palmear Audio Amplifier is not connected
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Palmear Audio Amplifier Not Connected'),
                        content: Text(
                            'Please connect the Palmear Audio Amplifier properly to the mobile phone.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
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
                  CircleBorder(),
                ),
              ),
              child: Container(
                width: 100,
                height: 100,
                child: Center(
                  child: Text(
                    isListening ? 'Stop' : 'Start',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              isListening
                  ? 'Press to stop listening'
                  : 'Press to start listening',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void startScan() {
    // TODO: Implement logic to start listening for audio input
    print('Listening...');
  }

  void stopScan() {
    // TODO: Implement logic to stop listening for audio input
    print('Stopped listening');
  }

  void startCountdown() {
    const oneSec = const Duration(seconds: 1);
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
