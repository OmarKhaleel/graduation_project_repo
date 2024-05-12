import 'package:flutter/material.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';

class AudioDevicesListView extends StatelessWidget {
  final List<AudioDeviceInfo> audioDevices;

  const AudioDevicesListView({super.key, required this.audioDevices});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: audioDevices.length,
      itemBuilder: (context, index) {
        final device = audioDevices[index];
        return ListTile(
          title: Text(
            device.name,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sample Rate: ${device.sampleRate} Hz',
                  style: const TextStyle(color: Colors.white)),
              Text('Channels: ${device.channels}',
                  style: const TextStyle(color: Colors.white)),
              Text('Callback Function: ${device.callbackFunction}',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }
}
