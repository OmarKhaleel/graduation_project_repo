package com.example.palmear_application;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.AudioDeviceInfo;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterActivity;
import org.jtransforms.fft.DoubleFFT_1D;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL_AUDIO = "com.example.palmear_application/audio";
    private static final String CHANNEL_DEVICES = "audio_devices";
    private static final int SAMPLE_RATE = 44100;
    private static final int BUFFER_SIZE = AudioRecord.getMinBufferSize(
            SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT
    );
    private AudioRecord audioRecord;
    private boolean isRecording = false;
    private final DoubleFFT_1D fft = new DoubleFFT_1D(BUFFER_SIZE);

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_AUDIO).setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "startRecording":
                            startRecording(result);
                            break;
                        case "stopRecording":
                            stopRecording(result);
                            break;
                        default:
                            result.notImplemented();
                    }
                }
        );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_DEVICES).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getAudioDevices")) {
                        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
                        AudioDeviceInfo[] devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);
                        List<Map<String, Object>> deviceList = new ArrayList<>();

                        for (AudioDeviceInfo device : devices) {
                            Map<String, Object> deviceInfo = new HashMap<>();
                            deviceInfo.put("name", device.getProductName().toString());
                            deviceInfo.put("sampleRate", device.getSampleRates().length > 0 ? device.getSampleRates()[0] : "Unknown");
                            deviceInfo.put("channels", device.getChannelCounts().length > 0 ? (device.getChannelCounts()[0] == 1 ? "mono" : "stereo") : "Unknown");
                            deviceInfo.put("callbackFunction", device.isSource() ? "Yes" : "No");
                            deviceList.add(deviceInfo);
                        }

                        result.success(deviceList);
                    } else {
                        result.notImplemented();
                    }
                }
        );
    }

    private void startRecording(MethodChannel.Result result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.RECORD_AUDIO}, 1);
            result.error("PERMISSION_DENIED", "Microphone permission denied", null);
            return;
        }

        isRecording = true;
        audioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, BUFFER_SIZE);

        audioRecord.startRecording();

        new Thread(() -> {
            short[] buffer = new short[BUFFER_SIZE];

            while (isRecording) {
                audioRecord.read(buffer, 0, BUFFER_SIZE);
                double[] fftData = new double[BUFFER_SIZE];
                for (int i = 0; i < BUFFER_SIZE; i++) {
                    fftData[i] = buffer[i];
                }
                fft.realForward(fftData);

                int maxMagnitudeIndex = findMaxMagnitudeIndex(fftData);
                double nyquistFrequency = SAMPLE_RATE / 2.0;
                double frequency = maxMagnitudeIndex * nyquistFrequency / BUFFER_SIZE;

                runOnUiThread(() -> {
                    MethodChannel methodChannel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL_AUDIO);
                    methodChannel.invokeMethod("updateFrequency", frequency);

                    // Spectrogram generation (just generating, not used for UI updates)
                    double[] spectrogram = performFFT(fftData);
                    methodChannel.invokeMethod("generateSpectrogram", spectrogram);
                });
            }

            audioRecord.release();
            audioRecord = null;
        }).start();

        result.success("Recording started");
    }

    private void stopRecording(MethodChannel.Result result) {
        isRecording = false;
        if (audioRecord != null) {
            audioRecord.stop();
            audioRecord.release();
            audioRecord = null;
        }
        result.success("Recording stopped");
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

    private double[] performFFT(double[] data) {
        DoubleFFT_1D fft = new DoubleFFT_1D(data.length);
        fft.realForward(data);

        double[] magnitudes = new double[data.length / 2];
        for (int i = 0; i < data.length / 2; i++) {
            double real = data[2 * i];
            double imag = data[2 * i + 1];
            magnitudes[i] = Math.sqrt(real * real + imag * imag);
        }
        return magnitudes;
    }
}
