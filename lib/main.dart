import 'package:flutter/material.dart';
import 'dart:async';

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
      debugShowCheckedModeBanner:
          false, // Add this line to hide the debug banner
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isListening = false;
  int countdown = 50;
  Timer? timer;

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
            const SizedBox(height: 20),
            Text(
              'Listening time: $countdown seconds',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isListening = !isListening;
                  countdown =
                      50; // Reset countdown when starting/stopping listening
                  if (isListening) {
                    startCountdown();
                    // Start listening
                    startScan();
                  } else {
                    // Stop listening
                    stopScan();
                    timer?.cancel(); // Cancel the countdown timer
                  }
                });
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
    // TODO: Implement logic to start listening for audio input
    print('Listening...');
  }

  void stopScan() {
    // TODO: Implement logic to stop listening for audio input
    print('Stopped listening');
  }

  void startCountdown() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          if (countdown < 1) {
            timer.cancel();
            isListening = false; // Automatically stop listening after countdown
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
    timer?.cancel(); // Cancel the countdown timer to avoid memory leaks
  }
}
