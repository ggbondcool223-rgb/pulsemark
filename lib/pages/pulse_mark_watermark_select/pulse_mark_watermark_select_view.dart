import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pulse_mark/common/colors.dart';
import 'pulse_mark_watermark_select_logic.dart';

class PulseMarkWatermarkSelectView
    extends GetView<PulseMarkWatermarkSelectLogic> {
  const PulseMarkWatermarkSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: primaryColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Select Photos',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ElevatedButton(
                onPressed: controller.onNextTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshPhotos,
                  color: primaryColor,
                  child: GridView.builder(
                    padding: EdgeInsets.all(16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.w,
                      childAspectRatio: 1.0,
                    ),
                    itemCount:
                        1 +
                        controller.capturedPhotos.length +
                        controller.photos.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildCameraButton();
                      }

                      final capturedCount = controller.capturedPhotos.length;
                      if (index <= capturedCount) {
                        final photoModel = controller.capturedPhotos[index - 1];
                        return _buildPhotoItem(photoModel, isCaptured: true);
                      }

                      final photoModel =
                          controller.photos[index - capturedCount - 1];
                      return _buildPhotoItem(photoModel, isCaptured: false);
                    },
                  ),
                );
              }),
            ),
            _buildBottomPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPreview() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: controller.clearAll,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 20.sp,
                      color: primaryColor,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Photos',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${controller.selectedCount} / ${controller.maxPhotos}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (controller.selectedPhotos.isNotEmpty) ...[
              SizedBox(height: 12.h),
              SizedBox(
                height: 60.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.selectedPhotos.length,
                  itemBuilder: (context, index) {
                    final photoItem = controller.selectedPhotos[index];

                    if (photoItem is AssetEntity) {
                      return FutureBuilder(
                        future: photoItem.thumbnailDataWithSize(
                          const ThumbnailSize(150, 150),
                        ),
                        builder: (context, snapshot) {
                          return _buildPreviewItem(index, snapshot.data);
                        },
                      );
                    } else if (photoItem is String) {
                      return FutureBuilder(
                        future: File(photoItem).readAsBytes(),
                        builder: (context, snapshot) {
                          return _buildPreviewItem(index, snapshot.data);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(int index, Uint8List? imageData) {
    return Container(
      width: 60.w,
      height: 68.h,
      margin: EdgeInsets.only(right: 10.w),
      child: Stack(
        children: [
          if (imageData != null)
            Padding(
              padding: EdgeInsets.only(top: 6.h, right: 6.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.memory(
                  imageData,
                  width: 60.w,
                  height: 68.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          Positioned(
            bottom: 4.h,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Positioned(
            top: 0.h,
            right: 0.w,
            child: GestureDetector(
              onTap: () => controller.removePhotoAt(index),
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: controller.openCamera,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Icons.camera_alt_rounded, size: 42.sp, color: Colors.white),
      ),
    );
  }

  Widget _buildPhotoItem(
    PhotoAssetModel photoModel, {
    bool isCaptured = false,
  }) {
    return Obx(() {
      final photoIdentifier = photoModel.asset ?? photoModel.filePath!;
      final isSelected = controller.isPhotoSelected(photoIdentifier);

      return GestureDetector(
        onTap: () => controller.togglePhoto(photoIdentifier),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Stack(
            children: [
              if (photoModel.thumbnail != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.memory(
                    photoModel.thumbnail!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Center(
                  child: Icon(
                    Icons.photo_rounded,
                    size: 40.sp,
                    color: const Color(0xFF999999),
                  ),
                ),

              if (isCaptured)
                Positioned(
                  top: 4.h,
                  left: 4.w,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                ),

              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.black.withOpacity(0.3),
                    border: Border.all(color: primaryColor, width: 3.w),
                  ),
                ),

              if (isSelected)
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.5),
                          blurRadius: 8.r,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
