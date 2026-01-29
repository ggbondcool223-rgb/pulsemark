import 'package:get/get.dart';
import 'pulse_mark_camera_logic.dart';

class PulseMarkCameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PulseMarkCameraLogic());
  }
}

