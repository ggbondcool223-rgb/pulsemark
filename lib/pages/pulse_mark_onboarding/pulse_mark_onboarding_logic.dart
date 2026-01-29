import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db_pulse_mark/data.dart';

class OnboardingStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class PulseMarkOnboardingLogic extends GetxController {
  late final PageController pageController;

  final currentPage = 0.obs;

  final List<OnboardingStep> steps = const [
    OnboardingStep(
      icon: Icons.camera_alt,
      title: 'Select Your Photos',
      description:
          'Choose photos from your camera or gallery to start editing',
      color: Color(0xFFFF6090),
    ),
    OnboardingStep(
      icon: Icons.edit,
      title: 'Edit & Customize',
      description:
          'Add watermarks, text, or split your images into grids for social media',
      color: Color(0xFF9C27B0),
    ),
    OnboardingStep(
      icon: Icons.save_alt,
      title: 'Save & Share',
      description:
          'Save your edited photos to gallery and share them with friends',
      color: Color(0xFF2196F3),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    pageController.addListener(_onPageChanged);
  }

  @override
  void onClose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.onClose();
  }

  void _onPageChanged() {
    if (pageController.hasClients) {
      final page = pageController.page?.round() ?? 0;
      if (currentPage.value != page) {
        currentPage.value = page;
      }
    }
  }

  void onPageChangedManually(int index) {
    currentPage.value = index;
  }

  Future<void> onSkip() async {
    await _completeOnboarding();
  }

  void onNext() {
    if (currentPage.value < steps.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      onFinish();
    }
  }

  Future<void> onFinish() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    try {
      final dao = AppSettingsDao();
      await dao.set('first_launch', 'false');

      Get.offAllNamed('/pulse_mark_tab');
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      Get.offAllNamed('/pulse_mark_tab');
    }
  }
}

