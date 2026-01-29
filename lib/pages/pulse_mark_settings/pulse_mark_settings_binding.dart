import 'package:get/get.dart';
import 'pulse_mark_settings_logic.dart';

class PulseMarkSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PulseMarkSettingsLogic());
  }
}

