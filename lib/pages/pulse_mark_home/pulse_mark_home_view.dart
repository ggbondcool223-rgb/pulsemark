import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pulse_mark/common/colors.dart';
import 'pulse_mark_home_logic.dart';

class PulseMarkHomeView extends GetView<PulseMarkHomeLogic> {
  const PulseMarkHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 4.w,
              height: 40.h,
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => primaryGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: Text(
                    'PulseMark',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Image Editing & Copywriting Tool',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: textSecondaryColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        height: 1.sh,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
                childAspectRatio: 1.0,
                children: [
                  _buildFeatureCard(
                    icon: Icons.water_drop_outlined,
                    title: 'Watermark',
                    subtitle: 'Add watermarks & text to photos',
                    gradient: reverseGradient,
                    onTap: () =>
                        Get.toNamed('/pulse_mark_watermark_select'),
                  ),
                  _buildFeatureCard(
                    icon: Icons.grid_on,
                    title: 'Grid Cut',
                    subtitle: 'Split images into 3×3 grid',
                    gradient: primaryGradient,
                    onTap: () => Get.toNamed('/pulse_mark_grid_cut'),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              _buildHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
        children: [
          Positioned(
            top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3.h,
                  decoration: BoxDecoration(gradient: gradient),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 26.sp, color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: textPrimaryColor,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: textSecondaryColor,
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.historyItems.isEmpty) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 24.h),
          padding: EdgeInsets.all(40.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 88.w,
                height: 88.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 44.sp,
                  color: primaryColor.withOpacity(0.4),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'No History Yet',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: textPrimaryColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Your saved watermarks and grid cuts\nwill appear here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: textSecondaryColor.withOpacity(0.8),
                  height: 1.7,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 30.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13.sp,
                      color: primaryColor,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Start creating to build your collection',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 24.h,
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Recent Works',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.historyItems.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final item = controller.historyItems[index];
              return _buildHistoryItem(item);
            },
          ),
        ],
      );
    });
  }

  Widget _buildHistoryItem(dynamic item) {
    final isWatermark = item.type == 'watermark';
    final crossAxisCount = _getGridColumns(item);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: isWatermark ? reverseGradient : primaryGradient,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isWatermark ? Icons.water_drop : Icons.grid_on,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isWatermark ? 'Watermark' : item.gridMode ?? 'Grid Cut',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  controller.getTimeAgo(item.createdAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: textSecondaryColor.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => controller.onDeleteTap(item),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20.sp,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 4.w,
                mainAxisSpacing: 4.h,
                childAspectRatio: 1.0,
              ),
              itemCount: item.imagePaths.length,
              itemBuilder: (context, index) {
                final imagePath = item.imagePaths[index];
                return GestureDetector(
                  onTap: () => controller.onImageTap(imagePath),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: File(imagePath).existsSync()
                        ? Image.file(File(imagePath), fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade400,
                              size: 24.sp,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  int _getGridColumns(dynamic item) {
    if (item.type == 'watermark') {
      return 3;
    }

    final gridMode = item.gridMode ?? '';
    if (gridMode.contains('9')) return 3;
    if (gridMode.contains('6')) return 3;
    if (gridMode.contains('4')) return 2;
    if (gridMode.contains('3')) return 3;
    return 3;
  }
}
