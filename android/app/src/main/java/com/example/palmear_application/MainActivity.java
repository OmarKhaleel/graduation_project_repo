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
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "audio_devices";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
            (call, result) -> {
                if (call.method.equals("getAudioDevices")) {
                    AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
                    AudioDeviceInfo[] devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);
                    List<Map<String, Object>> deviceList = new ArrayList<>();

                    for (AudioDeviceInfo device : devices) {
                        Map<String, Object> deviceInfo = new HashMap<>();
                        deviceInfo.put("name", device.getProductName().toString());
                        deviceInfo.put("sampleRate", device.getSampleRates()[0]); // Assuming the first sample rate is representative
                        deviceInfo.put("channels", device.getChannelCounts()[0] == 1 ? "mono" : "stereo");
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
}
