import 'package:palmear_application/domain/entities/audio_device_info.dart';

abstract class AudioDeviceRepository {
  Future<List<AudioDeviceInfo>> getAudioDevices();
}
