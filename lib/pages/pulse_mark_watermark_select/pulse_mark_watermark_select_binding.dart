import 'package:get/get.dart';
import 'pulse_mark_watermark_select_logic.dart';

class PulseMarkWatermarkSelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PulseMarkWatermarkSelectLogic());
  }
}

