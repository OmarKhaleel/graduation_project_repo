import 'package:flutter/material.dart';
import 'package:palmear_application/data/repositories/audio_device_repository.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';
import 'package:flutter/services.dart';
import 'package:usb_serial/usb_serial.dart';

class AudioDeviceRepositoryImpl implements AudioDeviceRepository {
  final MethodChannel _channel = const MethodChannel('audio_devices');

  @override
  Future<List<AudioDeviceInfo>> getAudioDevices() async {
    List<AudioDeviceInfo> audioDevices = [];

    // Fetch audio devices through native code
    try {
      final List<dynamic> devices =
          await _channel.invokeMethod('getAudioDevices');
      audioDevices = devices
          .map((device) => AudioDeviceInfo(device['name'], device['sampleRate'],
              device['channels'], device['callbackFunction']))
          .toList();
    } on PlatformException catch (e) {
      debugPrint("Failed to get audio devices: ${e.message}");
    }

    // Fetch USB devices
    try {
      List<UsbDevice> usbDevices = await UsbSerial.listDevices();
      for (var usbDevice in usbDevices) {
        audioDevices.add(AudioDeviceInfo(
          usbDevice.deviceName,
          0, // Sample rate
          'N/A', // Number of channels
          'N/A', // Callback function
        ));
      }
    } catch (e) {
      debugPrint("Failed to get USB devices: $e");
    }

    return audioDevices;
  }
}
