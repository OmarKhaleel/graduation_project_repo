package com.example.palmear_application;

import android.media.AudioFormat;
import android.media.AudioRecord;
import org.jtransforms.fft.DoubleFFT_1D;

public class AudioProcessor {
    private static final int SAMPLE_RATE = 44100;
    private static final int BUFFER_SIZE = AudioRecord.getMinBufferSize(
        SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT
    );
    private final DoubleFFT_1D fft;

    public AudioProcessor() {
        fft = new DoubleFFT_1D(BUFFER_SIZE);
    }

    public double calculateFrequency(short[] buffer) {
        double[] fftData = new double[BUFFER_SIZE];
        for (int i = 0; i < BUFFER_SIZE; i++) {
            fftData[i] = buffer[i];
        }
        fft.realForward(fftData);

        int maxMagnitudeIndex = findMaxMagnitudeIndex(fftData);
        double nyquistFrequency = SAMPLE_RATE / 2.0;
        return maxMagnitudeIndex * nyquistFrequency / BUFFER_SIZE;
    }

    private int findMaxMagnitudeIndex(double[] fftData) {
        int maxIndex = 0;
        double maxMagnitude = fftData[0];

        for (int i = 1; i < fftData.length / 2; i++) {
            if (fftData[i] > maxMagnitude) {
                maxMagnitude = fftData[i];
                maxIndex = i;
            }
        }

        return maxIndex;
    }

    public double[] generateSpectrogram(short[] buffer) {
        double[] fftData = new double[BUFFER_SIZE];
        for (int i = 0; i < BUFFER_SIZE; i++) {
            fftData[i] = buffer[i];
        }
        fft.realForward(fftData);

        double[] magnitudes = new double[BUFFER_SIZE / 2];
        for (int i = 0; i < BUFFER_SIZE / 2; i++) {
            double real = fftData[2 * i];
            double imag = fftData[2 * i + 1];
            magnitudes[i] = Math.sqrt(real * real + imag * imag);
        }
        return magnitudes;
    }
}
