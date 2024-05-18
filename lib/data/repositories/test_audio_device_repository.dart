import 'package:palmear_application/data/repositories/audio_device_repository.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';

class TestAudioDeviceRepository implements AudioDeviceRepository {
  @override
  Future<List<AudioDeviceInfo>> getAudioDevices() async {
    // Create a list of audio devices (mock data)
    return [
      AudioDeviceInfo('KM_B2 Digital Audio', 44100, 'stereo', 'Yes'),
      AudioDeviceInfo('External Microphone', 44100, 'stereo', 'Yes'),
    ];
  }
}
