import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';

List<List<double>> generateSimulatedSpectrogram(
    int frameCount, int sampleRate) {
  Random rng = math.Random();
  return List.generate(
    frameCount,
    (_) => List.generate(sampleRate, (_) => rng.nextDouble()),
  );
}

Color getColorFromSpectrogram(List<List<double>> spectrogram) {
  double avg = spectrogram.expand((x) => x).reduce((a, b) => a + b) /
      (spectrogram.length * spectrogram[0].length);
  if (avg > 0.53) {
    return Colors.red;
  } else if (avg > 0.4) {
    return Colors.green;
  } else if (avg > 0.51 && avg < 0.53) {
    return Colors.orange;
  } else {
    return Colors.orange;
  }
}
