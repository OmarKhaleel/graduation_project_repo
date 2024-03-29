import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';

class GetAudioDevices {
  final AudioDeviceRepositoryImpl repository;

  GetAudioDevices(this.repository);

  Future<List<AudioDeviceInfo>> call() {
    return repository.getAudioDevices();
  }
}
