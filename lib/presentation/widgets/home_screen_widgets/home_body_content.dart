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
import 'package:palmear_application/presentation/widgets/home_screen_widgets/custom_button_style.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/custom_icon.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/no_audio_devices_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/outside_area_dialog.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/palmear_audio_amplifier_status_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/ring_container_widget.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/scale_transition_widget.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/start_stop_listening_text.dart';
import 'package:provider/provider.dart';

class HomeBodyContent extends StatefulWidget {
  const HomeBodyContent({super.key});

  @override
  State<HomeBodyContent> createState() => _HomeBodyContentState();
}

class _HomeBodyContentState extends State<HomeBodyContent>
    with SingleTickerProviderStateMixin {
  bool isPalmearAudioAmplifierConnected = false;
  final audioDeviceRepository = AudioDeviceRepositoryImpl();
  bool _isListening = false;
  int _countdown = 50;
  Timer? timer;
  final TreeDetails _treeDetails = TreeDetails();
  late Position _currentLocation;
  bool _isUserInsideFarmValue = false;
  final AudioProcessor _audioProcessor = AudioProcessor();
  late AnimationController _animationController;
  late Animation<double> _animation;
  Color _iconColor = const Color(0xFF00916E); // Initial icon color

  @override
  void initState() {
    super.initState();
    checkPermission();
    _initUserInsideFarmChecker();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startCountdown() async {
    if (await _audioProcessor.requestMicrophonePermission()) {
      _audioProcessor.startStreaming();
      const oneSec = Duration(seconds: 1);
      timer = Timer.periodic(
        oneSec,
        (Timer timer) {
          setState(() {
            if (_countdown < 1) {
              timer.cancel();
              _isListening = false;
              _iconColor = const Color(0xFF00916E);
              _countdown = 50;
              _audioProcessor.stopStreaming();
              stopScan();
              _userInsideFarmOperations();
            } else {
              _countdown--;
            }
          });
        },
      );
    } else {
      showToast(message: 'Permission needed for prediction');
    }
  }

  Future<void> _initUserInsideFarmChecker() async {
    _currentLocation = (await getUserLocation())!;
    _isUserInsideFarmValue = await isUserInsideFarmChecker(_currentLocation);
  }

  Future<void> _userInsideFarmOperations() async {
    await userInsideFarmOperations(_currentLocation, _treeDetails);
  }

  @override
  void dispose() {
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
                const SizedBox(height: 100),
                CountdownText(countdown: _countdown),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isListening)
                      CustomScaleTransition(
                          animation: _animation), // Use the custom widget
                    RingContainer(
                      isListening: _isListening,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _initUserInsideFarmChecker();
                          if (!_isUserInsideFarmValue) {
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
                                }
                              });
                            }
                          }
                        },
                        style: customButtonStyle(_isListening, _countdown),
                        child: customIcon(_iconColor),
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
