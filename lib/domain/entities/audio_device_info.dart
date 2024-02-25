class AudioDeviceInfo {
  final String name;
  final int sampleRate;
  final String channels;
  final String callbackFunction;
  final int delay; // New field for audio delay

  AudioDeviceInfo(this.name, this.sampleRate, this.channels,
      this.callbackFunction, this.delay);
}
