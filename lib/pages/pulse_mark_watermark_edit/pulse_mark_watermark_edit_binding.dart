import 'package:get/get.dart';
import 'pulse_mark_watermark_edit_logic.dart';

class PulseMarkWatermarkEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PulseMarkWatermarkEditLogic());
  }
}

