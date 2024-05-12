import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  final bool isListening;
  final bool isPalmearAudioAmplifierConnected;
  final Function() onStartListening;
  final Function() onStopListening;
  final Function() onShowErrorDialog;

  const ScanButton({
    super.key,
    required this.isListening,
    required this.isPalmearAudioAmplifierConnected,
    required this.onStartListening,
    required this.onStopListening,
    required this.onShowErrorDialog,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (isPalmearAudioAmplifierConnected) {
          onShowErrorDialog();
        } else {
          if (isListening) {
            onStopListening();
          } else {
            onStartListening();
          }
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
        padding:
            MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(50)),
      ),
      child: const Icon(
        Icons.hearing,
        size: 100,
        color: Color(0xFF00916E),
      ),
    );
  }
}
