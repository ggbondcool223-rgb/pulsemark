import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_mark/common/colors.dart';
import 'pulse_mark_onboarding_logic.dart';

class PulseMarkOnboardingView extends GetView<PulseMarkOnboardingLogic> {
  const PulseMarkOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildPageView()),
          SizedBox(height: 20.h),
          _buildPageIndicator(),
          SizedBox(height: 40.h),
          _buildBottomButton(),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }


  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        Obx(() {
          if (controller.currentPage.value == controller.steps.length - 1) {
            return const SizedBox.shrink();
          }
          return TextButton(
            onPressed: controller.onSkip,
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 15.sp,
                color: textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
        SizedBox(width: 8.w),
      ],
    );
  }


  Widget _buildPageView() {
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: controller.onPageChangedManually,
      itemCount: controller.steps.length,
      itemBuilder: (context, index) {
        return _buildPage(controller.steps[index]);
      },
    );
  }

  Widget _buildPage(OnboardingStep step) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  step.color.withOpacity(0.8),
                  step.color.withOpacity(0.4),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: step.color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              step.icon,
              size: 80.sp,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 60.h),

          Text(
            step.title,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: textPrimaryColor,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20.h),

          Text(
            step.description,
            style: TextStyle(
              fontSize: 15.sp,
              color: textSecondaryColor,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildPageIndicator() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.steps.length,
          (index) => _buildDot(index),
        ),
      );
    });
  }

  Widget _buildDot(int index) {
    final isActive = controller.currentPage.value == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: isActive ? 24.w : 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }


  Widget _buildBottomButton() {
    return Obx(() {
      final isLastPage =
          controller.currentPage.value == controller.steps.length - 1;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: controller.onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Center(
                child: Text(
                  isLastPage ? 'Get Started' : 'Next',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

