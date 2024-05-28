package com.example.palmear_application;

import android.content.Context;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import androidx.annotation.NonNull;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterActivity;
import android.util.Log;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.palmear_application/audio";
    private static final String TAG = "MainActivity";

    private List<Double> performFFT(double[] data) {
        AudioProcessor processor = new AudioProcessor();
        return processor.performFFT(data);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
            (call, result) -> {
                switch (call.method) {
                    case "getAudioDevices":
                        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
                        AudioDeviceInfo[] devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);
                        List<Map<String, Object>> deviceList = new ArrayList<>();

                        for (AudioDeviceInfo device : devices) {
                            Map<String, Object> deviceInfo = new HashMap<>();
                            deviceInfo.put("name", device.getProductName().toString());
                            deviceInfo.put("sampleRate", device.getSampleRates()[0]);
                            deviceInfo.put("channels", device.getChannelCounts()[0] == 1 ? "mono" : "stereo");
                            deviceInfo.put("callbackFunction", device.isSource() ? "Yes" : "No");
                            deviceList.add(deviceInfo);
                        }

                        result.success(deviceList);
                        break;
                    case "getSpectrogram":
                        ArrayList<Double> window = call.argument("window");
                        if (window == null) {
                            result.error("NULL_WINDOW", "The 'window' argument is null", null);
                            return;
                        }
                        Log.d(TAG, "Window size: " + window.size());
                        double[] windowArray = window.stream().mapToDouble(Double::doubleValue).toArray();
                        List<Double> spectrogram = performFFT(windowArray);
                        List<Double> normalizedSpectrogram = normalizeSpectrogram(spectrogram);
                        result.success(normalizedSpectrogram);
                        break;

                    default:
                        result.notImplemented();
                }
            }
        );
    }

    private List<Double> normalizeSpectrogram(List<Double> spectrogram) {
        double maxVal = Double.NEGATIVE_INFINITY;
        double minVal = Double.POSITIVE_INFINITY;

        for (double value : spectrogram) {
            if (value > maxVal) {
                maxVal = value;
            }
            if (value < minVal) {
                minVal = value;
            }
        }

        List<Double> normalized = new ArrayList<>();
        for (double value : spectrogram) {
            double normalizedValue = (value - minVal) / (maxVal - minVal);
            normalized.add(normalizedValue);
        }
        return normalized;
    }
}
