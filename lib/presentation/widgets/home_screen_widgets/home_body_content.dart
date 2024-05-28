import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/data/services/audio_services/audio_services.dart';
import 'package:palmear_application/data/services/provider_services/audio_device_provider.dart';
import 'package:palmear_application/data/services/tree_services/tree_details.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/get_user_location.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/is_user_inside_farm_checker.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/location_permission.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/scan_utils.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/user_inside_farm_operations.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/amplifier_not_connected_dialog.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/audio_devices_list_view.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/countdown_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/no_audio_devices_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/outside_area_dialog.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/palmear_audio_amplifier_status_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/start_stop_listening_text.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class HomeBodyContent extends StatefulWidget {
  const HomeBodyContent({super.key});

  @override
  State<HomeBodyContent> createState() => _HomeBodyContentState();
}

class _HomeBodyContentState extends State<HomeBodyContent>
    with SingleTickerProviderStateMixin {
  static const MethodChannel _platform =
      MethodChannel('com.example.palmear_application/audio');

  bool isPalmearAudioAmplifierConnected = false;
  final audioDeviceRepository = AudioDeviceRepositoryImpl();
  bool _isListening = false;
  int _countdown = 50;
  Timer? timer;
  final TreeDetails _treeDetails = TreeDetails();
  late Position _currentLocation;
  bool _isUserInsideFarmValue = false;
  late AudioProcessor _audioProcessor;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Color _iconColor = const Color(0xFF00916E); // Initial icon color
  Color _buttonBackgroundColor = Colors.white;
  final List<double> _currentSecondFrequencies = [];
  int _redColorCount = 0;
  String _resultLabel = "Healthy";
  String _scanStatusMessage = ""; // State variable for scan status message

  @override
  void initState() {
    super.initState();
    checkPermission();
    _audioProcessor = AudioProcessor();
    _initUserInsideFarmChecker();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'updateFrequency':
          double frequency = call.arguments;
          _currentSecondFrequencies.add(frequency);
          break;
        case 'generateSpectrogram':
          // List<dynamic> spectrogram = call.arguments;
          break;
        default:
          throw MissingPluginException();
      }
    });
  }

  Future<void> updateUI(double averageFrequency) async {
    Color? newColor = await _audioProcessor.processFrequency(averageFrequency);
    if (newColor != null) {
      if (!mounted) return;
      setState(() {
        _buttonBackgroundColor = newColor;
        if (_buttonBackgroundColor == Colors.red) {
          _redColorCount++;
        }
        if (_redColorCount == 10) {
          // Adjust the threshold as needed
          _resultLabel = "Infested";
          _stopListening();
        }
      });
    }
  }

  void _startCountdown() async {
    setState(() {
      _scanStatusMessage = "Scanning.."; // Set initial scanning message
    });

    if (await _audioProcessor.requestMicrophonePermission()) {
      _resultLabel = "Healthy";
      _audioProcessor.startStreaming();
      const oneSec = Duration(seconds: 1);
      timer = Timer.periodic(
        oneSec,
        (Timer timer) {
          if (!mounted) return; // Check if the widget is still mounted
          setState(() {
            if (_countdown < 1) {
              _stopListening();
            } else {
              double averageFrequency = _currentSecondFrequencies.isEmpty
                  ? 0.0
                  : _currentSecondFrequencies.reduce((a, b) => a + b) /
                      _currentSecondFrequencies.length;
              _currentSecondFrequencies.clear();
              updateUI(averageFrequency);

              _countdown--;
            }
          });
        },
      );
    } else {
      showToast(message: 'Permission needed for prediction');
    }
  }

  void _stopListening() async {
    timer?.cancel(); // Stop the timer
    _isListening = false;
    _iconColor = const Color(0xFF00916E);
    if (_countdown < 1 || _redColorCount == 10) {
      _userInsideFarmOperations();
    }
    _countdown = 50;
    _audioProcessor.stopStreaming();
    stopScan();
    _redColorCount = 0;

    _scanStatusMessage = "The last scan result came back as $_resultLabel";
  }

  Future<void> _initUserInsideFarmChecker() async {
    _currentLocation = (await getUserLocation())!;
    _isUserInsideFarmValue = await isUserInsideFarmChecker(_currentLocation);
  }

  Future<void> _userInsideFarmOperations() async {
    await userInsideFarmOperations(
      _treeDetails,
      _resultLabel,
    );
  }

  @override
  void dispose() {
    if (_isListening) {
      _stopListening();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioDeviceProvider>(
      builder: (context, audioDeviceProvider, child) {
        return SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (audioDeviceProvider.audioDevices.isEmpty)
                  const NoAudioDevicesText()
                else
                  AudioDevicesListView(
                      audioDevices: audioDeviceProvider.audioDevices),
                const SizedBox(height: 10),
                PalmearAudioAmplifierStatusText(
                    isPalmearAudioAmplifierConnected:
                        audioDeviceProvider.isPalmearAudioAmplifierConnected),
                const SizedBox(height: 80),
                if (_scanStatusMessage.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _scanStatusMessage == "Scanning.."
                              ? 'Scanning..'
                              : 'The last scan result came back as ',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        if (_scanStatusMessage != "Scanning..")
                          TextSpan(
                            text: _resultLabel,
                            style: TextStyle(
                              color: _resultLabel == "Healthy"
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                CountdownText(countdown: _countdown),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isListening)
                      ScaleTransition(
                        scale: _animation,
                        child: Container(
                          width:
                              250, // Increase width for wider pulsating range
                          height:
                              200, // Increase height for wider pulsating range
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(
                                0.2), // White color with transparency
                          ),
                        ),
                      ), // Use the custom widget
                    Container(
                      width: 200, // width of the outer circle
                      height: 200, // height of the outer circle
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isListening
                              ? Colors.transparent
                              : const Color(
                                  0xFF24BF86), // Hide ring when listening
                          width: 10, // width of the ring
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await _initUserInsideFarmChecker();
                          if (!_isUserInsideFarmValue) {
                            if (!mounted) {
                              return; // Check if the widget is still mounted
                            }
                            showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (BuildContext context) {
                                return const OutsideAreaDialog(); // Use the custom widget
                              },
                            );
                          } else {
                            if (audioDeviceProvider
                                .isPalmearAudioAmplifierConnected) {
                              if (!mounted) {
                                return; // Check if the widget is still mounted
                              }
                              showDialog(
                                // ignore: use_build_context_synchronously
                                context: context,
                                builder: (BuildContext context) {
                                  return const AmplifierNotConnectedDialog(); // Use the custom widget
                                },
                              );
                            } else {
                              setState(() {
                                _isListening = !_isListening;
                                _countdown = 50;
                                _redColorCount = 0;
                                _iconColor = _isListening
                                    ? Colors.white
                                    : const Color(
                                        0xFF00916E); // Change icon color

                                if (_isListening) {
                                  _startCountdown();
                                  startScan();
                                  _animationController.repeat();
                                } else {
                                  stopScan();
                                  timer?.cancel();
                                  _audioProcessor.stopStreaming();
                                  _animationController.stop();
                                  _scanStatusMessage = "";
                                }
                              });
                            }
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return _isListening
                                  ? _buttonBackgroundColor
                                  : Colors.white;
                            },
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.hearing,
                          size: 100,
                          color: _iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StartStopListeningText(isListening: _isListening),
              ],
            ),
          ),
        );
      },
    );
  }
}
