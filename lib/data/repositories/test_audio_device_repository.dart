import 'package:palmear_application/data/repositories/audio_device_repository.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';

class TestAudioDeviceRepository implements AudioDeviceRepository {
  @override
  Future<List<AudioDeviceInfo>> getAudioDevices() async {
    // Create a list of audio devices (mock data)
    return [
      AudioDeviceInfo('Palmear Device', 44100, 'stereo', 'Yes'),
      AudioDeviceInfo('Other Device', 48000, 'stereo', 'No'),
    ];
  }
}
