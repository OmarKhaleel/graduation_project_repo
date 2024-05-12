import 'dart:async';

class CountdownController {
  final Function(int) onCountdownChanged;
  final Function onCountdownCompleted;
  Timer? timer;
  int initialCountdown;

  CountdownController({
    required this.onCountdownChanged,
    required this.onCountdownCompleted,
    this.initialCountdown = 50,
  });

  void startCountdown(int countdown) {
    stopCountdown(); // Ensure any existing timer is stopped before starting a new one
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (countdown < 1) {
          resetAndStopCountdown();
        } else {
          countdown--;
          onCountdownChanged(countdown);
        }
      },
    );
  }

  void stopCountdown() {
    timer?.cancel();
  }

  void resetAndStopCountdown() {
    stopCountdown();
    onCountdownChanged(initialCountdown);
    onCountdownCompleted();
  }
}
