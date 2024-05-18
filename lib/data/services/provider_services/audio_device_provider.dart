import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/data/repositories/test_audio_device_repository.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/platform_utils.dart';

class AudioDeviceProvider extends ChangeNotifier {
  List<AudioDeviceInfo> _audioDevices = [];
  bool _isPalmearAudioAmplifierConnected = false;
  final bool _isTesting = Platform.environment.containsKey('FLUTTER_TEST');
  late StreamSubscription _audioDeviceSubscription;

  List<AudioDeviceInfo> get audioDevices => _audioDevices;
  bool get isPalmearAudioAmplifierConnected =>
      _isPalmearAudioAmplifierConnected;

  AudioDeviceProvider() {
    _initialize();
  }

  void _initialize() {
    _audioDeviceSubscription =
        Stream.periodic(const Duration(seconds: 1)).listen((_) {
      _getAudioDevices();
    });
  }

  Future<void> _getAudioDevices() async {
    try {
      final audioDeviceRepository = _isTesting
          ? TestAudioDeviceRepository()
          : AudioDeviceRepositoryImpl();
      final devices = await audioDeviceRepository.getAudioDevices();
      final deviceMap = <String, AudioDeviceInfo>{};

      for (final device in devices) {
        if (!deviceMap.containsKey(device.name) ||
            device.sampleRate > deviceMap[device.name]!.sampleRate) {
          deviceMap[device.name] = device;
        }
      }

      _audioDevices = deviceMap.values.toList();

      if (PlatformUtils.isAndroid) {
        _isPalmearAudioAmplifierConnected = _audioDevices.any((device) =>
            device.name.toLowerCase().contains('km_b2 digital audio'));
      } else if (PlatformUtils.isIOS) {
        _isPalmearAudioAmplifierConnected = _audioDevices.any((device) =>
            device.name.toLowerCase().contains('external microphone'));
      } else {
        // Do nothing
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to get audio devices: '$e'.");
    }
  }

  @override
  void dispose() {
    _audioDeviceSubscription.cancel();
    super.dispose();
  }
}
