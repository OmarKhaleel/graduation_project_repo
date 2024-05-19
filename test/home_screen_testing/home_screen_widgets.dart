import 'dart:async';
import 'package:flutter/material.dart';
import 'package:palmear_application/data/repositories/test_audio_device_repository.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/scan_utils.dart';
import 'package:palmear_application/presentation/screens/map_screen.dart';
import 'package:palmear_application/presentation/screens/settings_screen.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/bottom_navigation_bar.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/amplifier_not_connected_dialog.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/audio_devices_list_view.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/countdown_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/get_button_color.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/no_audio_devices_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/outside_area_dialog.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/palmear_audio_amplifier_status_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/start_stop_listening_text.dart';

class MyHomePageTest extends StatefulWidget {
  const MyHomePageTest({super.key});

  @override
  State<MyHomePageTest> createState() => _MyHomePageTestState();
}

class _MyHomePageTestState extends State<MyHomePageTest> {
  int _selectedIndex = 0;
  bool _isListening = false;
  int _countdown = 50;
  Timer? timer;
  bool _isPalmearAudioAmplifierConnected = false;
  List<AudioDeviceInfo> _audioDevices = [];
  final bool _isUserInsideFarmValue =
      true; // Assuming the user is inside his farm
  Color _iconColor = const Color(0xFF00916E); // Initial icon color

  @override
  void initState() {
    super.initState();
    _getAudioDevices();
  }

  Future<void> _getAudioDevices() async {
    try {
      TestAudioDeviceRepository testAudioDeviceRepository =
          TestAudioDeviceRepository();
      final devices = await testAudioDeviceRepository.getAudioDevices();
      final deviceMap = <String, AudioDeviceInfo>{};

      for (final device in devices) {
        if (!deviceMap.containsKey(device.name) ||
            device.sampleRate > deviceMap[device.name]!.sampleRate) {
          deviceMap[device.name] = device;
        }
      }
      setState(() {
        _audioDevices = deviceMap.values.toList();
        _isPalmearAudioAmplifierConnected = _audioDevices.any((device) =>
            device.name.toLowerCase().contains('km_b2 digital audio'));
      });
    } catch (e) {
      debugPrint("Failed to get audio devices: '$e'.");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const MapScreen();
      case 2:
        return const SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  void _startCountdown() {
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
            stopScan();
          } else {
            _countdown--;
          }
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_audioDevices.isEmpty)
              const NoAudioDevicesText()
            else
              AudioDevicesListView(audioDevices: _audioDevices),
            const SizedBox(height: 10),
            PalmearAudioAmplifierStatusText(
                isPalmearAudioAmplifierConnected:
                    _isPalmearAudioAmplifierConnected),
            const SizedBox(height: 100),
            CountdownText(countdown: _countdown),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (!_isUserInsideFarmValue) {
                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (BuildContext context) {
                          return const OutsideAreaDialog(); // Use the custom widget
                        },
                      );
                    } else {
                      if (!_isPalmearAudioAmplifierConnected) {
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
                              : const Color(0xFF00916E); // Change icon color
                          if (_isListening) {
                            _startCountdown();
                            startScan();
                          } else {
                            stopScan();
                            timer?.cancel();
                          }
                        });
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return _isListening
                            ? getButtonColor(_countdown)
                            : Colors.white;
                      },
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
              ],
            ),
            const SizedBox(height: 20),
            StartStopListeningText(isListening: _isListening),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pest Detection',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF00916E),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: const Color(0xFF00916E),
        body: _buildPageContent(),
        bottomNavigationBar: BottomNavigationBarScreen(
          selectedIndex: _selectedIndex,
          onItemSelected: _onItemTapped,
        ));
  }
}
