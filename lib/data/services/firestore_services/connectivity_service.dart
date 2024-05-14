import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:palmear_application/data/services/firestore_services/sync_manager.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final SyncManager _syncManager = SyncManager();
  ConnectivityService() {
    initializeConnectivityListener();
  }

  void initializeConnectivityListener() {
    try {
      _connectivitySubscription = _connectivity.onConnectivityChanged
          .listen((List<ConnectivityResult> results) {
        bool isConnected =
            results.any((result) => result != ConnectivityResult.none);
        debugPrint('Connectivity change detected: $isConnected');
        if (isConnected) {
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
