import 'package:flutter/material.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';
import 'package:flutter/services.dart';

class AudioDeviceRepositoryImpl {
  final MethodChannel _channel = const MethodChannel('audio_devices');

  Future<List<AudioDeviceInfo>> getAudioDevices() async {
    try {
      final List<dynamic> devices =
          await _channel.invokeMethod('getAudioDevices');
      return devices
          .map((device) => AudioDeviceInfo(device['name'], device['sampleRate'],
              device['channels'], device['callbackFunction']))
          .toList();
    } on PlatformException catch (e) {
      debugPrint("Failed to get audio devices: ${e.message}");
      return [];
    }
  }
}
