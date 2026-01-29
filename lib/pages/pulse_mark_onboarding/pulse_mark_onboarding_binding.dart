import 'package:get/get.dart';
import 'pulse_mark_onboarding_logic.dart';

class PulseMarkOnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PulseMarkOnboardingLogic());
  }
}
