import 'dart:async';
import 'package:flutter/material.dart';
import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/data/repositories/test_audio_device_repository.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';

Future<List<AudioDeviceInfo>> getAudioDevices({required bool isTesting}) async {
  try {
    final audioDeviceRepository =
        isTesting ? TestAudioDeviceRepository() : AudioDeviceRepositoryImpl();
    final devices = await audioDeviceRepository.getAudioDevices();
    final deviceMap = <String, AudioDeviceInfo>{};

    for (final device in devices) {
      if (!deviceMap.containsKey(device.name) ||
          device.sampleRate > deviceMap[device.name]!.sampleRate) {
        deviceMap[device.name] = device;
      }
    }

    return deviceMap.values.toList();
  } catch (e) {
    debugPrint("Failed to get audio devices: '$e'.");
    return [];
  }
}
