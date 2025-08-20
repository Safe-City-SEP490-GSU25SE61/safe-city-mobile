import 'dart:async';
import 'package:get/get.dart';

class PauseController extends GetxController {
  static PauseController get instance => Get.find();

  RxInt pauseChances = 2.obs;
  RxInt remainingSeconds = 0.obs;
  Timer? _timer;

  void startPause() {
    if (pauseChances.value <= 0) return;

    pauseChances.value--;

    remainingSeconds.value = 300;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        stopPause();
      }
    });
  }

  void stopPause() {
    _timer?.cancel();
    remainingSeconds.value = 0;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}