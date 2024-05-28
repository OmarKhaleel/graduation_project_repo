// audio_device_repository_impl.dart
import 'package:flutter/material.dart';
import 'package:palmear_application/data/repositories/audio_device_repository.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';
import 'package:flutter/services.dart';

class AudioDeviceRepositoryImpl implements AudioDeviceRepository {
  final MethodChannel _channel = const MethodChannel('audio_devices');

  @override
  Future<List<AudioDeviceInfo>> getAudioDevices() async {
    try {
      final List<dynamic> devices =
          await _channel.invokeMethod('getAudioDevices');
      return devices
          .map((device) => AudioDeviceInfo(
                device['name'],
                device['sampleRate'],
                device['channels'],
                device['callbackFunction'],
              ))
          .toList();
    } on PlatformException catch (e) {
      debugPrint("Failed to get audio devices: ${e.message}");
      return [];
    }
  }
}
