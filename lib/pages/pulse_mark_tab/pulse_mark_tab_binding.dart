import 'package:get/get.dart';
import 'pulse_mark_tab_logic.dart';
import '../pulse_mark_home/pulse_mark_home_logic.dart';
import '../pulse_mark_settings/pulse_mark_settings_logic.dart';

class PulseMarkTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PulseMarkTabLogic());
    Get.lazyPut(() => PulseMarkHomeLogic());
    Get.lazyPut(() => PulseMarkSettingsLogic());
  }
}

