import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:palmear_application/data/services/firestore_services/sync_manager.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final SyncManager _syncManager = SyncManager();

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

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
