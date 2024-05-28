import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL_AUDIO = "com.example.palmear_application/audio"
    private let CHANNEL_DEVICES = "audio_devices"
    private var audioEngine: AVAudioEngine!
    private var isRecording = false

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let audioChannel = FlutterMethodChannel(name: CHANNEL_AUDIO, binaryMessenger: controller.binaryMessenger)
        let deviceChannel = FlutterMethodChannel(name: CHANNEL_DEVICES, binaryMessenger: controller.binaryMessenger)

        audioChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            switch call.method {
            case "startRecording":
                self.startRecording(result: result)
            case "stopRecording":
                self.stopRecording(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        deviceChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            if call.method == "getAudioDevices" {
                self.getAudioDevices(result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func startRecording(result: @escaping FlutterResult) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)

            audioEngine = AVAudioEngine()
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                self.processAudioBuffer(buffer: buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
            result("Recording started")
        } catch {
            result(FlutterError(code: "AUDIO_ENGINE_ERROR", message: "Could not start audio engine", details: nil))
        }
    }

    private func stopRecording(result: @escaping FlutterResult) {
        if isRecording {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            isRecording = false
            result("Recording stopped")
        } else {
            result(FlutterError(code: "NOT_RECORDING", message: "Audio is not recording", details: nil))
        }
    }

    private func processAudioBuffer(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelData[$0] }

        // Perform FFT and get the frequency
        let fft = FFT(bufferSize: channelDataArray.count)
        fft.calculate(samples: channelDataArray)
        let frequency = fft.maxFrequency

        DispatchQueue.main.async {
            let audioChannel = FlutterMethodChannel(name: self.CHANNEL_AUDIO, binaryMessenger: self.window?.rootViewController as! FlutterViewController)
            audioChannel.invokeMethod("updateFrequency", arguments: frequency)

            // Generate spectrogram data (optional)
            let spectrogram = fft.spectrogram()
            audioChannel.invokeMethod("generateSpectrogram", arguments: spectrogram)
        }
    }

    private func getAudioDevices(result: FlutterResult) {
        let audioSession = AVAudioSession.sharedInstance()
        let inputs = audioSession.availableInputs ?? []

        var deviceList: [[String: Any]] = []
        for device in inputs {
            var deviceInfo: [String: Any] = [:]
            deviceInfo["name"] = device.portName
            deviceInfo["sampleRate"] = 44100 // Sample rate can be queried if needed
            deviceInfo["channels"] = device.channels > 1 ? "stereo" : "mono"
            deviceInfo["callbackFunction"] = device.portType == .builtInMic ? "Yes" : "No"
            deviceList.append(deviceInfo)
        }

        result(deviceList)
    }
}
