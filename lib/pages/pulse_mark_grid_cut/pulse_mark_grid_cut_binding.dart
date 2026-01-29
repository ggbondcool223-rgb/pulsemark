import 'package:get/get.dart';
import 'pulse_mark_grid_cut_logic.dart';

class PulseMarkGridCutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PulseMarkGridCutLogic());
  }
}

