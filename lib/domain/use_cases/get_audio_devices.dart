import 'package:palmear_application/domain/entities/audio_device_info.dart';
import 'package:palmear_application/data/repositories/audio_device_repository.dart';

class GetAudioDevices {
  final AudioDeviceRepository repository;

  GetAudioDevices(this.repository);

  Future<List<AudioDeviceInfo>> call() {
    return repository.getAudioDevices();
  }
}
