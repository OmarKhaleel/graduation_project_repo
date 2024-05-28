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

  final bool _isConnected = false;
  bool get isConnected => _isConnected;

  void initializeConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      bool isConnected =
          results.any((result) => result != ConnectivityResult.none);
      if (isConnected) {
        showToast(message: "Device connected to Internet.");
        _syncManager.syncToFirestore();
      } else {
        showToast(message: "No internet connection.");
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
