import 'package:get/get.dart';

import 'pulse_mark_auth_logic.dart';

class PulseMarkAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      PulseMarkAuthLogic(),
      permanent: true,
    );
  }
}
