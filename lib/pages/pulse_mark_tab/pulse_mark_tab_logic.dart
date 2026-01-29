import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pulse_mark_home/pulse_mark_home_logic.dart';

class PulseMarkTabLogic extends GetxController {
  final currentIndex = 0.obs;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onTabTap(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);

    if (index == 0) {
      try {
        final homeLogic = Get.find<PulseMarkHomeLogic>();
        homeLogic.loadHistory();
      } catch (e) {
        debugPrint('Home logic not found: $e');
      }
    }
  }

  void onCameraTap() {
    Get.toNamed('/pulse_mark_camera');
  }
}
