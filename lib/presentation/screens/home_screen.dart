import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;
import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/data/repositories/farm_repository.dart';
import 'package:palmear_application/data/repositories/test_audio_device_repository.dart';
import 'package:palmear_application/data/repositories/tree_repository.dart';
import 'package:palmear_application/data/services/tree_services/tree_details.dart';
import 'package:palmear_application/data/services/user_services/audio_services.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';
import 'package:palmear_application/domain/entities/audio_device_info.dart';
import 'package:palmear_application/domain/entities/farm_model.dart';
import 'package:palmear_application/domain/entities/tree_model.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/scan_utils.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/bottom_navigation_bar.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/audio_devices_list_view.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/countdown_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/no_audio_devices_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/palmear_audio_amplifier_status_text.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/start_stop_listening_text.dart';
import 'map_screen.dart';
import 'settings_screen.dart';
import 'dart:io' show Platform;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<AudioDeviceInfo> _audioDevices = [];
  bool isPalmearAudioAmplifierConnected = false;
  final audioDeviceRepository = AudioDeviceRepositoryImpl();
  final bool _isTesting = Platform.environment.containsKey('FLUTTER_TEST');
  bool _isListening = false;
  int _countdown = 50;
  Timer? timer;
  final TreeDetails _treeDetails = TreeDetails();
  late Position _currentLocation;
  bool _isUserInsideFarmValue = false;
  FarmModel? _selectedFarm;
  final AudioProcessor _audioProcessor = AudioProcessor();

  // Test for live location
  double lat = 0;
  double lng = 0;

  @override
  void initState() {
    super.initState();
    _getAudioDevices();
    _checkPermission();
    _isUserInsideFarmChecker();
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

  Future<void> _getAudioDevices() async {
    try {
      final audioDeviceRepository = _isTesting
          ? TestAudioDeviceRepository()
          : AudioDeviceRepositoryImpl();
      final devices = await audioDeviceRepository.getAudioDevices();
      final deviceMap = <String, AudioDeviceInfo>{};

      for (final device in devices) {
        if (!deviceMap.containsKey(device.name) ||
            device.sampleRate > deviceMap[device.name]!.sampleRate) {
          deviceMap[device.name] = device;
        }
      }
      setState(() {
        _audioDevices = deviceMap.values.toList();
        isPalmearAudioAmplifierConnected = _audioDevices.any((device) =>
            device.name.toLowerCase().contains('external microphone'));
      });
    } catch (e) {
      debugPrint("Failed to get audio devices: '$e'.");
    }
  }

  void startCountdown() async {
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
              _countdown = 50;
              _audioProcessor.stopStreaming();
              stopScan();
              _isUserInsideFarmOperations();
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

  //check if location permission is enable
  Future<bool> _checkPermission() async {
    bool isEnable = false;
    LocationPermission permission;

    //check if location is enable
    isEnable = await Geolocator.isLocationServiceEnabled();
    if (!isEnable) {
      return false;
    }

    //check if use allow location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // if permission is denied then request user to allow permission again
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // if permission denied again
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _isUserInsideFarmChecker() async {
    var sessionUser = UserSession().getUser();
    if (sessionUser != null) {
      var farmRepository = FarmRepository(userId: sessionUser.uid);
      var farms = await farmRepository.getFarms();

      if (farms.isNotEmpty) {
        _currentLocation = (await _getUserLocation())!;
        for (var farm in farms) {
          _isUserInsideFarmValue = toolkit.PolygonUtil.containsLocation(
            toolkit.LatLng(
                _currentLocation.latitude, _currentLocation.longitude),
            farm.locations
                .map((e) => toolkit.LatLng(e.latitude, e.longitude))
                .toList(),
            true,
          );
        }
      }
    }
  }

  Future<void> _isUserInsideFarmOperations() async {
    var sessionUser = UserSession().getUser();
    if (sessionUser != null) {
      var farmRepository = FarmRepository(userId: sessionUser.uid);
      var farms = await farmRepository.getFarms();

      if (farms.isNotEmpty) {
        _currentLocation = (await _getUserLocation())!;
        for (var farm in farms) {
          _isUserInsideFarmValue = toolkit.PolygonUtil.containsLocation(
            toolkit.LatLng(
                _currentLocation.latitude, _currentLocation.longitude),
            farm.locations
                .map((e) => toolkit.LatLng(e.latitude, e.longitude))
                .toList(),
            true,
          );
          if (_isUserInsideFarmValue) {
            _selectedFarm = farm;
            var treeRepository =
                TreeRepository(userId: sessionUser.uid, farmId: farm.uid);
            List<TreeModel> trees = await treeRepository.getTrees();

            TreeModel? nearestTree;
            double nearestDistance = double.infinity;

            for (var tree in trees) {
              double distance = toolkit.SphericalUtil.computeDistanceBetween(
                toolkit.LatLng(
                    _currentLocation.latitude, _currentLocation.longitude),
                toolkit.LatLng(tree.location.latitude, tree.location.longitude),
              ).toDouble();

              if (distance < nearestDistance) {
                nearestTree = tree;
                nearestDistance = distance;
              }
            }

            if (nearestDistance > 3) {
              String label = "Infested";
              double latitude = _currentLocation.latitude;
              double longitude = _currentLocation.longitude;

              _treeDetails.addTreeToUserFarm(
                label,
                latitude,
                longitude,
                _selectedFarm!.uid,
              );
            } else if (nearestTree != null) {
              String label = "Healthy";
              _treeDetails.updateSelectedTreeLabel(nearestTree.uid, label);
            } else {
              showToast(
                  message:
                      "Something wrong happened when checking for nearby trees.");
            }
          } else {
            showToast(
                message:
                    "Something wrong happened when trying to locate your location.");
          }
        }
      }
    }
  }

  //get user current location
  Future<Position?> _getUserLocation() async {
    debugPrint("Fetching location...");
    var isEnable = await _checkPermission();
    if (isEnable) {
      Position currentLocation = await Geolocator.getCurrentPosition();
      lat = currentLocation.latitude;
      lng = currentLocation.longitude;
      debugPrint("Location: Lat: ${lat.toString()}, Lng: ${lng.toString()}");

      return currentLocation;
    } else {
      debugPrint("Location permission denied");
      return null;
    }
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
                  isPalmearAudioAmplifierConnected,
            ),
            const SizedBox(height: 100),
            CountdownText(countdown: _countdown),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _isUserInsideFarmChecker();
                if (!_isUserInsideFarmValue) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Out of your authorized area!'),
                        content: const Text(
                            'You can\'t scan trees that aren\'t inside your farm. Please make sure you\'re inside your farm to be able to scan.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  if (isPalmearAudioAmplifierConnected) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                              'Palmear Audio Amplifier Not Connected'),
                          content: const Text(
                              'Please connect the Palmear Audio Amplifier properly to the mobile phone.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    setState(() {
                      _isListening = !_isListening;
                      _countdown = 50;
                      if (_isListening) {
                        startCountdown();
                        startScan();
                      } else {
                        stopScan();
                        timer?.cancel();
                        _audioProcessor.stopStreaming();
                      }
                    });
                  }
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return _isListening ? Colors.red : Colors.white;
                  },
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
                padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.all(50)),
              ),
              child: const Icon(
                Icons.hearing,
                size: 100,
                color: Color(0xFF00916E),
              ),
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
        title:
            const Text('Pest Detection', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00916E),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Implement action
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFF00916E),
      body: _buildPageContent(),
      bottomNavigationBar: BottomNavigationBarScreen(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
