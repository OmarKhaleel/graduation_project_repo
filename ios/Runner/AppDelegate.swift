import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "audio_devices"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "getAudioDevices" {
                let session = AVAudioSession.sharedInstance()
                do {
                    try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
                    let availableInputs = session.availableInputs ?? []
                    var deviceList = [[String: Any]]()
                    for input in availableInputs {
                        var deviceInfo = [String: Any]()
                        deviceInfo["name"] = input.portName
                        deviceInfo["sampleRate"] = session.sampleRate
                        deviceInfo["channels"] = input.channels == 1 ? "mono" : "stereo"
                        deviceInfo["callbackFunction"] = input.dataSources != nil ? "Yes" : "No"
                        deviceInfo["deviceDelay"] = input.deviceDelay ?? 0
                        deviceList.append(deviceInfo)
                    }
                    result(deviceList)
                } catch {
                    result(FlutterError(code: "AVSessionError", message: "Failed to get audio devices", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}