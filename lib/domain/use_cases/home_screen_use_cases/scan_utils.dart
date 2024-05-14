import 'package:flutter/material.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';

void startScan() {
  showToast(message: 'Listening...');
  debugPrint('Listening...');
}

void stopScan() {
  showToast(message: 'Stopped listening');
  debugPrint('Stopped listening');
}
