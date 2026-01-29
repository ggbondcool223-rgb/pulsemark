import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pulse_mark/common/colors.dart';
import 'pulse_mark_grid_cut_logic.dart';

class PulseMarkGridCutView extends GetView<PulseMarkGridCutLogic> {
  const PulseMarkGridCutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: primaryColor),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final mode = controller.currentMode.value;
          return Text(
            'Grid Cut ($mode)',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          );
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_library, size: 22.sp, color: primaryColor),
            onPressed: controller.onSelectPhoto,
            tooltip: 'Change Photo',
          ),
          SizedBox(width: 8.w),
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Obx(() {
              final hasImage = controller.selectedImage.value != null;
              final isSaving = controller.isSaving.value;

              return ElevatedButton(
                onPressed: hasImage && !isSaving ? controller.onSaveAll : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasImage
                      ? primaryColor
                      : Colors.grey.shade300,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: isSaving
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Save All',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: hasImage ? Colors.white : textSecondaryColor,
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(0.w),
              child: Obx(() {
                final uiImage = controller.uiImage.value;
                final isLoading = controller.isLoading.value;
                final isSaving = controller.isSaving.value;
                final savingProgress = controller.savingProgress.value;
                controller.gridRects.length;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Stack(
                    children: [
                      if (uiImage != null)
                        _buildGridPreview(uiImage)
                      else
                        _buildPlaceholder(),

                      if (isLoading)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),

                      if (isSaving && savingProgress.isNotEmpty)
                        Positioned(
                          bottom: 16.h,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                savingProgress,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Obx(() {
            final currentMode = controller.currentMode.value;
            final hasImage = controller.uiImage.value != null;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildToolButton(
                    Icons.grid_on,
                    '9 Grid',
                    hasImage,
                    selected: currentMode == '9 Grid',
                    onTap: () => controller.changeGridMode('9 Grid'),
                  ),
                  _buildToolButton(
                    Icons.grid_4x4,
                    '6 Grid',
                    hasImage,
                    selected: currentMode == '6 Grid',
                    onTap: () => controller.changeGridMode('6 Grid'),
                  ),
                  _buildToolButton(
                    Icons.grid_3x3,
                    '4 Grid',
                    hasImage,
                    selected: currentMode == '4 Grid',
                    onTap: () => controller.changeGridMode('4 Grid'),
                  ),
                  _buildToolButton(
                    Icons.grid_goldenratio,
                    '3 Grid',
                    hasImage,
                    selected: currentMode == '3 Grid',
                    onTap: () => controller.changeGridMode('3 Grid'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 80.sp, color: textHintColor),
          SizedBox(height: 16.h),
          Text(
            'Select a photo to start',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: textHintColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your image will be split into 3×3 grid',
            style: TextStyle(fontSize: 12.sp, color: textSecondaryColor),
          ),
          SizedBox(height: 24.h),
          Container(
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ElevatedButton.icon(
              onPressed: controller.onSelectPhoto,
              icon: Icon(Icons.add, size: 20.sp),
              label: Text(
                'Choose Photo',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridPreview(ui.Image image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: CustomPaint(
        painter: GridCutPainter(image: image, gridRects: controller.gridRects),
        child: Container(),
      ),
    );
  }

  Widget _buildToolButton(
    IconData icon,
    String label,
    bool enabled, {
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: selected ? primaryColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: selected ? primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? primaryColor : textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridCutPainter extends CustomPainter {
  final ui.Image image;
  final List<Rect> gridRects;

  GridCutPainter({required this.image, required this.gridRects});

  @override
  void paint(Canvas canvas, Size size) {
    _drawCheckerboard(canvas, size);

    final imageAspect = image.width / image.height;
    final canvasAspect = size.width / size.height;

    double drawWidth, drawHeight;
    double offsetX = 0, offsetY = 0;

    if (imageAspect > canvasAspect) {
      drawWidth = size.width;
      drawHeight = size.width / imageAspect;
      offsetY = (size.height - drawHeight) / 2;
    } else {
      drawHeight = size.height;
      drawWidth = size.height * imageAspect;
      offsetX = (size.width - drawWidth) / 2;
    }

    final dstRect = Rect.fromLTWH(offsetX, offsetY, drawWidth, drawHeight);
    final srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    final gridPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final scaleX = drawWidth / image.width;
    final scaleY = drawHeight / image.height;

    for (int i = 0; i < gridRects.length; i++) {
      final rect = gridRects[i];
      final scaledRect = Rect.fromLTWH(
        offsetX + rect.left * scaleX,
        offsetY + rect.top * scaleY,
        rect.width * scaleX,
        rect.height * scaleY,
      );

      canvas.drawRect(scaledRect, gridPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0.sp,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.8),
                offset: const Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      final centerX = scaledRect.center.dx - textPainter.width / 2;
      final centerY = scaledRect.center.dy - textPainter.height / 2;
      textPainter.paint(canvas, Offset(centerX, centerY));
    }
  }

  void _drawCheckerboard(Canvas canvas, Size size) {
    const squareSize = 20.0;
    final paint = Paint();

    for (double x = 0; x < size.width; x += squareSize) {
      for (double y = 0; y < size.height; y += squareSize) {
        final isEven = ((x ~/ squareSize) + (y ~/ squareSize)) % 2 == 0;
        paint.color = isEven ? Colors.grey.shade200 : Colors.grey.shade300;
        canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(GridCutPainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.gridRects != gridRects;
  }
}
