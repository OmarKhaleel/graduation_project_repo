import 'package:flutter/material.dart';
import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/data/services/home_screen_services/audio_devices_service.dart';
import 'dart:async';
import 'package:palmear_application/domain/entities/audio_device_info.dart';

class AudioDeviceNotifier extends ChangeNotifier {
  List<AudioDeviceInfo> _audioDevices = [];
  String _deviceStatus = 'No audio devices connected';
  Timer? _timer;
  bool isTesting = false;

  AudioDeviceNotifier(AudioDeviceRepositoryImpl audioDeviceRepositoryImpl) {
    _startListening();
  }

  List<AudioDeviceInfo> get audioDevices => _audioDevices;
  String get deviceStatus => _deviceStatus;

  void _startListening() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      List<AudioDeviceInfo> devices =
          await getAudioDevices(isTesting: isTesting);
      if (devices.isEmpty) {
        _deviceStatus = 'No audio devices connected';
      } else {
        _deviceStatus = 'Audio device connected: ${devices.first.name}';
      }
      _audioDevices = devices;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
