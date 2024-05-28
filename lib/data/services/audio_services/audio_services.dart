import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';

class AudioProcessor {
  static const MethodChannel _platform =
      MethodChannel('com.example.palmear_application/audio');

  Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  void startStreaming() async {
    bool granted = await requestMicrophonePermission();
    if (granted) {
      _platform.invokeMethod('startRecording');
    } else {
      showToast(message: 'Microphone permission denied');
    }
  }

  void stopStreaming() {
    _platform.invokeMethod('stopRecording');
  }

  Future<Color?> processFrequency(double frequency) async {
    if (frequency > 1000) {
      return Colors.orange; // Too loud
    } else if (frequency > 750) {
      return Colors.red; // Close to the mic
    }
    return Colors.green; // Normal room sounds
  }
}
