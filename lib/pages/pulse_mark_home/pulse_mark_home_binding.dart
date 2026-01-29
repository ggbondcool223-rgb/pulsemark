import 'package:get/get.dart';
import 'pulse_mark_home_logic.dart';

class PulseMarkHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PulseMarkHomeLogic());
  }
}

