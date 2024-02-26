class AudioDeviceInfo {
  final String name;
  final int sampleRate;
  final String channels;
  final String callbackFunction;

  AudioDeviceInfo(
      this.name, this.sampleRate, this.channels, this.callbackFunction);
}
