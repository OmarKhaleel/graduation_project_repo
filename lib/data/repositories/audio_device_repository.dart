import 'package:flutter/services.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';

class AudioDeviceRepository {
  static const MethodChannel _channel = MethodChannel('audio_devices');

  Future<List<AudioDeviceInfo>> getAudioDevices() async {
    try {
      final List<dynamic> devices =
          await _channel.invokeMethod('getAudioDevices');
      return devices
          .map((device) => AudioDeviceInfo(device['name'], device['sampleRate'],
              device['channels'], device['callbackFunction'], device['delay']))
          .toList();
    } on PlatformException catch (e) {
      throw Exception("Failed to get audio devices: ${e.message}");
    }
  }
}
