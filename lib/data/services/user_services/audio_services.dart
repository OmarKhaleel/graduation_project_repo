import 'dart:async';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';

class AudioProcessor {
  AudioStreamer? _streamer;
  final List<double> _audioBuffer = [];
  StreamSubscription<List<double>>? _audioSubscription;

  Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  void startStreaming() async {
    bool granted = await requestMicrophonePermission();
    if (granted) {
      _streamer = AudioStreamer();
      _audioSubscription = _streamer!.audioStream.listen((data) {
        _audioBuffer.addAll(data);
      });
    } else {
      showToast(message: 'Microphone permission denied');
    }
  }

  void stopStreaming() {
    if (_audioSubscription != null) {
      _audioSubscription!.cancel();
      _audioSubscription = null;
      _streamer = null;
      int bufferLength = _audioBuffer.length;
      showToast(message: 'Audio stopped. Buffer Length: $bufferLength');
      _audioBuffer.clear();
    }
  }
}
