import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:palmear_application/data/services/firestore_services/sync_manager.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';

class ConnectivityService extends ChangeNotifier {
  // Singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();

  // Factory constructor to return the same instance
  factory ConnectivityService() {
    return _instance;
  }

  // Private constructor
  ConnectivityService._internal() {
    initializeConnectivityListener();
  }

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final SyncManager _syncManager = SyncManager();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void initializeConnectivityListener() {
    try {
      _connectivitySubscription = _connectivity.onConnectivityChanged
          .listen((List<ConnectivityResult> result) {
        // ignore: unrelated_type_equality_checks
        _isConnected =
            result.any((result) => result != ConnectivityResult.none);
        debugPrint('Connectivity change detected: $_isConnected');
        notifyListeners();

        if (_isConnected) {
          showToast(message: "Device connected to Internet.");
          _syncManager.syncToFirestore();
        } else {
          showToast(message: "No internet connection.");
        }
      });
    } catch (e) {
      debugPrint('Failed to set up connectivity listener: $e');
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
