import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_mark/common/colors.dart';
import 'pulse_mark_tab_logic.dart';
import 'package:pulse_mark/pages/pulse_mark_home/pulse_mark_home_view.dart';
import 'package:pulse_mark/pages/pulse_mark_settings/pulse_mark_settings_view.dart';

class PulseMarkTabView extends GetView<PulseMarkTabLogic> {
  const PulseMarkTabView({super.key});

  static final List<Widget> _pages = [
    const PulseMarkHomeView(),
    const PulseMarkSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 90.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                BottomNavigationBar(
                  currentIndex: controller.currentIndex.value == 0 ? 0 : 2,
                  onTap: (index) {
                    if (index == 1) {
                      controller.onCameraTap();
                      return;
                    }
                    controller.onTabTap(index == 0 ? 0 : 1);
                  },
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: primaryColor,
                  unselectedItemColor: const Color(0xFF999999),
                  selectedFontSize: 12.sp,
                  unselectedFontSize: 12.sp,
                  selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Icon(Icons.home, size: 22.sp),
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox(width: 24.w, height: 24.w),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Icon(Icons.settings, size: 22.sp),
                      ),
                      label: 'Settings',
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: -18.h,
                  child: Center(
                    child: GestureDetector(
                      onTap: controller.onCameraTap,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              gradient: primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Camera',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
