import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;
import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/data/repositories/farm_repository.dart';
import 'package:palmear_application/data/repositories/tree_repository.dart';
import 'package:palmear_application/data/services/provider_services/audio_device_provider.dart';
import 'package:palmear_application/data/services/tree_services/tree_details.dart';
import 'package:palmear_application/data/services/audio_services/audio_services.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';
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
import 'package:provider/provider.dart';
import 'map_screen.dart';
import 'settings_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool isPalmearAudioAmplifierConnected = false;
  final audioDeviceRepository = AudioDeviceRepositoryImpl();
  bool _isListening = false;
  int _countdown = 50;
  Timer? timer;
  final TreeDetails _treeDetails = TreeDetails();
  late Position _currentLocation;
  bool _isUserInsideFarmValue = false;
  FarmModel? _selectedFarm;
  final AudioProcessor _audioProcessor = AudioProcessor();
  late AnimationController _animationController;
  late Animation<double> _animation;
  Color _iconColor = const Color(0xFF00916E); // Initial icon color

  // Test for live location
  double lat = 0;
  double lng = 0;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _isUserInsideFarmChecker();

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

  Color _getButtonColor() {
    if (_countdown > 30) {
      return Colors.green;
    } else if (_countdown > 10) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildHomeContent() {
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
                      ),
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
                        onPressed: () {
                          _isUserInsideFarmChecker();
                          if (!_isUserInsideFarmValue) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                      'Out of your authorized area!'),
                                  content: const Text(
                                      'You can\'t scan trees that aren\'t inside your farm. Please make sure you\'re inside your farm to be able to scan.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            if (audioDeviceProvider
                                .isPalmearAudioAmplifierConnected) {
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
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
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
                                _iconColor = _isListening
                                    ? Colors.white
                                    : const Color(
                                        0xFF00916E); // Change icon color

                                if (_isListening) {
                                  startCountdown();
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
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return _isListening
                                  ? _getButtonColor()
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Pest Detection', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00916E),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFF00916E),
      body: Consumer<AudioDeviceProvider>(
        builder: (context, notifier, child) {
          return _buildPageContent();
        },
      ),
      bottomNavigationBar: BottomNavigationBarScreen(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
