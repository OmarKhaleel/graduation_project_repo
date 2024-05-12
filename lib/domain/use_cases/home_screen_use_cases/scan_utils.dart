import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';

void startScan() {
  showToast(message: 'Listening...');
}

void stopScan() {
  showToast(message: 'Stopped listening');
}
