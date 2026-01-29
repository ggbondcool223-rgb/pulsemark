import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulse_mark/common/colors.dart';
import 'package:pulse_mark/models/watermark_element.dart';
import 'package:pulse_mark/components/text_field.dart';
import 'package:pulse_mark/utils/index.dart';
import 'pulse_mark_watermark_edit_logic.dart';

class PulseMarkWatermarkEditView extends GetView<PulseMarkWatermarkEditLogic> {
  const PulseMarkWatermarkEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          'Edit Watermark',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.undo, size: 22.sp, color: Colors.white),
            onPressed: controller.undo,
          ),
          IconButton(
            icon: Icon(Icons.redo, size: 22.sp, color: Colors.white),
            onPressed: controller.redo,
          ),
          SizedBox(width: 8.w),
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Obx(
              () => Container(
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.onSaveTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? SizedBox(
                          width: 14.sp,
                          height: 14.sp,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.8),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.updateContainerSize(
                      Size(constraints.maxWidth, constraints.maxHeight),
                    );
                  });

                  return Stack(
                    children: [
                      Obx(() {
                        if (controller.isLoading.value) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryColor,
                              ),
                            ),
                          );
                        }

                        if (controller.currentPhotoData == null) {
                          return const Center(
                            child: Icon(
                              Icons.image,
                              size: 120,
                              color: Colors.grey,
                            ),
                          );
                        }

                        return InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          panEnabled: !controller.isDrawingMode.value,
                          scaleEnabled: !controller.isDrawingMode.value,
                          child: Center(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (!controller.isDrawingMode.value) {
                                  controller.selectElement(null);
                                }
                              },
                              onPanStart: controller.isDrawingMode.value
                                  ? (details) {
                                      controller.startDrawing(
                                        details.localPosition,
                                      );
                                    }
                                  : null,
                              onPanUpdate: controller.isDrawingMode.value
                                  ? (details) {
                                      controller.updateDrawing(
                                        details.localPosition,
                                      );
                                    }
                                  : null,
                              onPanEnd: controller.isDrawingMode.value
                                  ? (_) {
                                      controller.endDrawing();
                                    }
                                  : null,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Obx(() {
                                    final size =
                                        controller.displayedImageSize.value;
                                    return Image.memory(
                                      controller.currentPhotoData!,
                                      width: size?.width,
                                      height: size?.height,
                                      fit: BoxFit.contain,
                                    );
                                  }),
                                  ..._buildWatermarkElements(),
                                  Obx(() {
                                    controller.drawingUpdateTrigger.value;

                                    if (controller.drawingStrokes.isEmpty &&
                                        !controller.isDrawingMode.value) {
                                      return const SizedBox.shrink();
                                    }

                                    return Positioned.fill(
                                      child: CustomPaint(
                                        painter: DrawingPainter(
                                          strokes: controller.drawingStrokes,
                                          currentStroke:
                                              controller.currentStroke,
                                          isEraserMode:
                                              controller.isDrawingMode.value &&
                                              controller.isEraserMode.value,
                                          eraserPosition:
                                              controller.eraserPosition,
                                          eraserRadius:
                                              controller.eraserRadius.value,
                                        ),
                                      ),
                                    );
                                  }),
                                  if (controller.photoDataList.length > 1)
                                    Positioned(
                                      bottom: 8.h,
                                      right: 8.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: primaryGradient,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Text(
                                          '${controller.currentPhotoIndex.value + 1}/${controller.photoDataList.length}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      Obx(() {
                        if (!controller.hasPreviousPhoto) {
                          return const SizedBox();
                        }
                        return Positioned(
                          left: 12.w,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: controller.previousPhoto,
                              child: _buildNavigationButton(Icons.chevron_left),
                            ),
                          ),
                        );
                      }),
                      Obx(() {
                        if (!controller.hasNextPhoto) {
                          return const SizedBox();
                        }
                        return Positioned(
                          right: 12.w,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: controller.nextPhoto,
                              child: _buildNavigationButton(
                                Icons.chevron_right,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            _buildBottomTools(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 32.sp, color: Colors.white),
    );
  }

  List<Widget> _buildWatermarkElements() {
    return controller.watermarkElements.map((element) {
      return Obx(() {
        final currentElement = controller.watermarkElements.firstWhere(
          (e) => e.id == element.id,
          orElse: () => element,
        );
        final isSelected = controller.selectedElementId.value == element.id;

        final baseSize = _getElementBaseSize(currentElement);
        final scaledWidth = baseSize.width * currentElement.scale;
        final scaledHeight = baseSize.height * currentElement.scale;

        return Positioned(
          left: currentElement.position.dx,
          top: currentElement.position.dy,
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: controller.isDrawingMode.value
                ? null
                : () => controller.selectElement(element.id),
            onPanUpdate: controller.isDrawingMode.value
                ? null
                : (details) {
                    controller.updateElementPosition(element.id, details.delta);
                  },
            child: SizedBox(
              width: scaledWidth,
              height: scaledHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: scaledWidth,
                    height: scaledHeight,
                    color: Colors.transparent, // Ensure hit test
                    child: Transform.scale(
                      scale: currentElement.scale,
                      alignment: Alignment.topLeft,
                      child: Opacity(
                        opacity: currentElement.opacity,
                        child: Container(
                          decoration: BoxDecoration(
                            border: isSelected
                                ? Border.all(color: primaryColor, width: 2)
                                : null,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: _buildElementContent(currentElement),
                        ),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      left: -6.w,
                      top: -6.h,
                      child: Listener(
                        onPointerDown: (_) {},
                        onPointerMove: (_) {},
                        child: GestureDetector(
                          onTap: () => controller.deleteElement(element.id),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      });
    }).toList();
  }

  Size _getElementBaseSize(WatermarkElement element) {
    switch (element.type) {
      case WatermarkType.avatar:
        return Size(WatermarkBaseSizes.avatar.w, WatermarkBaseSizes.avatar.w);
      case WatermarkType.stamp:
        return Size(WatermarkBaseSizes.stamp.w, WatermarkBaseSizes.stamp.w);
      case WatermarkType.timeLocation:
        final baseSize = WatermarkBaseSizes.getTimeLocationSize(
          element.templateId,
        );
        return Size(baseSize.width.w, baseSize.height.h);
      case WatermarkType.customImage:
        return Size(
          WatermarkBaseSizes.customImage.w,
          WatermarkBaseSizes.customImage.w,
        );
      case WatermarkType.text:
        if (element.text != null && element.text!.isNotEmpty) {
          final textWidth = element.text!.length * 10.0;
          return Size(textWidth.clamp(50.0, 200.0), 30.0);
        }
        return Size(100.w, 30.h);
    }
  }

  Widget _buildElementContent(WatermarkElement element) {
    switch (element.type) {
      case WatermarkType.avatar:
        if (element.userImagePath != null && element.imagePath != null) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(
                  File(element.userImagePath!),
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      color: Colors.black54,
                      size: 40.sp,
                    );
                  },
                ),
              ),
              Image.asset(
                element.imagePath!,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox();
                },
              ),
            ],
          );
        }
        return Icon(Icons.person, color: Colors.black54, size: 40.sp);

      case WatermarkType.timeLocation:
        if (element.dynamicData != null && element.templateId != null) {
          return _buildTimeLocationPreviewWidget(element);
        }
        return Icon(Icons.location_on, color: Colors.black54, size: 40.sp);

      case WatermarkType.stamp:
        if (element.imagePath != null && element.imagePath!.isNotEmpty) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                element.imagePath!,
                width: 70.w,
                height: 70.w,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.verified, color: Colors.red, size: 40.sp);
                },
              ),
              if (element.stampText != null && element.stampText!.isNotEmpty)
                (element.stampTextVertical ?? false)
                    ? // Vertical text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: element.stampText!.split('').map((char) {
                          return Text(
                            char,
                            style: TextStyle(
                              fontSize: (element.stampTextSize ?? 20) * 0.5,
                              fontWeight: FontWeight.bold,
                              color:
                                  element.stampTextColor ??
                                  const Color(0xFF8B0000),
                              height: 1.2,
                            ),
                          );
                        }).toList(),
                      )
                    : // Horizontal text
                      Container(
                        constraints: BoxConstraints(maxWidth: 60.w),
                        child: Text(
                          element.stampText!,
                          style: TextStyle(
                            fontSize: (element.stampTextSize ?? 20) * 0.5,
                            fontWeight: FontWeight.bold,
                            color:
                                element.stampTextColor ??
                                const Color(0xFF8B0000),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
            ],
          );
        }
        return Icon(Icons.verified, color: Colors.red, size: 40.sp);

      case WatermarkType.customImage:
        if (element.imagePath != null) {
          return Image.file(
            File(element.imagePath!),
            width: 100.w,
            height: 100.w,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.image, color: Colors.black54, size: 40.sp);
            },
          );
        }
        return Icon(Icons.image, color: Colors.black54, size: 40.sp);

      case WatermarkType.text:
        if (element.text != null && element.text!.isNotEmpty) {
          return Text(
            element.text!,
            style: TextStyle(
              fontSize: (element.textSize ?? 32) * 0.3,
              color: element.textColor ?? Colors.white,
              fontWeight: element.isBold ?? false
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontStyle: element.isItalic ?? false
                  ? FontStyle.italic
                  : FontStyle.normal,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          );
        }
        return Icon(Icons.text_fields, color: Colors.white70, size: 40.sp);
    }
  }

  Widget _buildBottomTools() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(top: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Obx(() {
        if (controller.isDrawingMode.value) {
          return _buildDrawTools();
        }
        if (controller.selectedElementId.value != null &&
            controller.selectedElement != null) {
          return _buildElementSettings(controller.selectedElement!);
        }
        if (controller.selectedCategory.value.isNotEmpty) {
          return _buildTemplateSelection();
        }
        return _buildToolButtons();
      }),
    );
  }

  Widget _buildToolButtons() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 12.w,
        top: 14.h,
        bottom: 24.h,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToolButton(
              Icons.person_outline,
              'Avatar',
              () => controller.selectCategory('avatar'),
            ),
            SizedBox(width: 16.w),
            _buildToolButton(
              Icons.verified_outlined,
              'Stamp',
              () => controller.selectCategory('stamp'),
            ),
            SizedBox(width: 16.w),
            _buildToolButton(
              Icons.access_time,
              'Time/Place',
              () => _onTimeLocationTap(),
            ),
            SizedBox(width: 16.w),
            _buildToolButton(
              Icons.text_fields,
              'Text',
              () => _showTextInputDialog(),
            ),
            SizedBox(width: 16.w),
            _buildToolButton(
              Icons.image_outlined,
              'Gallery',
              () => controller.addCustomImageWatermark(),
            ),
            SizedBox(width: 16.w),
            _buildToolButton(
              Icons.brush_outlined,
              'Draw',
              () => controller.activateDrawingMode(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelection() {
    WatermarkType type;
    List<WatermarkTemplate> templates;

    switch (controller.selectedCategory.value) {
      case 'avatar':
        type = WatermarkType.avatar;
        templates = WatermarkTemplates.avatarTemplates;
        break;
      case 'timeLocation':
        type = WatermarkType.timeLocation;
        templates = WatermarkTemplates.timeLocationTemplates;
        break;
      case 'stamp':
        type = WatermarkType.stamp;
        templates = WatermarkTemplates.stampTemplates;
        break;
      default:
        return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select ${controller.selectedCategory.value[0].toUpperCase()}${controller.selectedCategory.value.substring(1)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
                onPressed: () => controller.selectCategory(''),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _buildTemplateCard(template, type, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementSettings(WatermarkElement element) {
    return Container(
      constraints: BoxConstraints(maxHeight: 280.h),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
          top: 8.h,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconForType(element.type),
                        color: primaryColor,
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${_getTypeName(element.type)} Settings',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 20.sp),
                    onPressed: () => controller.selectElement(null),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _buildScaleControl(element),
              SizedBox(height: 8.h),
              _buildOpacityControl(element),
              if (element.type == WatermarkType.stamp) ...[
                SizedBox(height: 8.h),
                _buildStampTextSettings(element),
              ],
              if (element.type == WatermarkType.text) ...[
                SizedBox(height: 8.h),
                _buildTextSettings(element),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeName(WatermarkType type) {
    switch (type) {
      case WatermarkType.avatar:
        return 'Avatar';
      case WatermarkType.timeLocation:
        return 'Time/Location';
      case WatermarkType.stamp:
        return 'Stamp';
      case WatermarkType.customImage:
        return 'Image';
      case WatermarkType.text:
        return 'Text';
    }
  }

  Widget _buildScaleControl(WatermarkElement element) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scale',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(element.scale * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.zoom_out, color: Colors.white70, size: 16.sp),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 12.r),
                  ),
                  child: Slider(
                    value: element.scale,
                    min: 0.3,
                    max: 3.0,
                    divisions: 27,
                    activeColor: primaryColor,
                    inactiveColor: Colors.grey.shade600,
                    onChanged: (value) {
                      controller.updateElementScaleValue(element.id, value);
                    },
                  ),
                ),
              ),
              Icon(Icons.zoom_in, color: Colors.white70, size: 16.sp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpacityControl(WatermarkElement element) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Opacity',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(element.opacity * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.opacity, color: Colors.white70, size: 16.sp),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 12.r),
                  ),
                  child: Slider(
                    value: element.opacity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    activeColor: primaryColor,
                    inactiveColor: Colors.grey.shade600,
                    onChanged: (value) {
                      controller.updateElementOpacity(element.id, value);
                    },
                  ),
                ),
              ),
              Icon(Icons.opacity, color: Colors.white, size: 16.sp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStampTextSettings(WatermarkElement element) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Stamp Text',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          MyTextField(
            value: element.stampText ?? '',
            maxLength: 20,
            maxLines: 1,
            hintText: 'Enter stamp text...',
            textStyle: TextStyle(color: Colors.white, fontSize: 12.sp),
            bgColor: Colors.grey.shade700,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
              borderSide: BorderSide.none,
            ),
            onChange: (value) {
              controller.updateStampText(element.id, value);
            },
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                'Direction',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.updateStampTextVertical(element.id, false);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          decoration: BoxDecoration(
                            gradient:
                                (element.stampTextVertical ?? false) == false
                                ? primaryGradient
                                : null,
                            color: (element.stampTextVertical ?? false) == false
                                ? null
                                : Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.text_fields,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Horizontal',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.updateStampTextVertical(element.id, true);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          decoration: BoxDecoration(
                            gradient:
                                (element.stampTextVertical ?? false) == true
                                ? primaryGradient
                                : null,
                            color: (element.stampTextVertical ?? false) == true
                                ? null
                                : Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.text_rotation_none,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Vertical',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white,
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
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Text Size',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Text(
                '${(element.stampTextSize ?? 20).toInt()}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 12.r),
            ),
            child: Slider(
              value: element.stampTextSize ?? 20,
              min: 10,
              max: 40,
              divisions: 30,
              activeColor: primaryColor,
              inactiveColor: Colors.grey.shade600,
              onChanged: (value) {
                controller.updateStampTextSize(element.id, value);
              },
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Text Color',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Row(
                children: [
                  _buildColorOption(
                    element,
                    const Color(0xFF8B0000),
                  ), // Dark red
                  SizedBox(width: 6.w),
                  _buildColorOption(element, Colors.red),
                  SizedBox(width: 6.w),
                  _buildColorOption(element, Colors.black),
                  SizedBox(width: 6.w),
                  _buildColorOption(element, Colors.white),
                  SizedBox(width: 6.w),
                  _buildColorOption(element, Colors.blue),
                  SizedBox(width: 6.w),
                  _buildColorOption(element, Colors.green),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(WatermarkElement element, Color color) {
    final isSelected =
        (element.stampTextColor ?? const Color(0xFF8B0000)) == color;
    return GestureDetector(
      onTap: () {
        controller.updateStampTextColor(element.id, color);
      },
      child: Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade600,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryColor.withOpacity(0.5),
                blurRadius: 6,
                spreadRadius: 0.5,
              ),
          ],
        ),
        child: isSelected
            ? Icon(Icons.check, size: 12.sp, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildTextSettings(WatermarkElement element) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Text Content',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          MyTextField(
            value: element.text ?? '',
            maxLength: 100,
            minLines: 1,
            maxLines: 3,
            hintText: 'Enter text...',
            textStyle: TextStyle(color: Colors.white, fontSize: 12.sp),
            bgColor: Colors.grey.shade700,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
              borderSide: BorderSide.none,
            ),
            onChange: (value) {
              controller.updateTextContent(element.id, value);
            },
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Text Size',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Text(
                '${(element.textSize ?? 32).toInt()}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 12.r),
            ),
            child: Slider(
              value: element.textSize ?? 32,
              min: 12,
              max: 80,
              divisions: 68,
              activeColor: primaryColor,
              inactiveColor: Colors.grey.shade600,
              onChanged: (value) {
                controller.updateTextSize(element.id, value);
              },
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Text Color',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Row(
                children: [
                  _buildTextColorOption(element, Colors.white),
                  SizedBox(width: 6.w),
                  _buildTextColorOption(element, Colors.black),
                  SizedBox(width: 6.w),
                  _buildTextColorOption(element, Colors.red),
                  SizedBox(width: 6.w),
                  _buildTextColorOption(element, Colors.blue),
                  SizedBox(width: 6.w),
                  _buildTextColorOption(element, Colors.green),
                  SizedBox(width: 6.w),
                  _buildTextColorOption(element, Colors.yellow),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                'Style',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.updateTextBold(
                            element.id,
                            !(element.isBold ?? false),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          decoration: BoxDecoration(
                            gradient: (element.isBold ?? false)
                                ? primaryGradient
                                : null,
                            color: (element.isBold ?? false)
                                ? null
                                : Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.format_bold,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Bold',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.updateTextItalic(
                            element.id,
                            !(element.isItalic ?? false),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          decoration: BoxDecoration(
                            gradient: (element.isItalic ?? false)
                                ? primaryGradient
                                : null,
                            color: (element.isItalic ?? false)
                                ? null
                                : Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.format_italic,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Italic',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextColorOption(WatermarkElement element, Color color) {
    final isSelected = (element.textColor ?? Colors.white) == color;
    return GestureDetector(
      onTap: () {
        controller.updateTextColor(element.id, color);
      },
      child: Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade600,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryColor.withOpacity(0.5),
                blurRadius: 6,
                spreadRadius: 0.5,
              ),
          ],
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 12.sp,
                color: color == Colors.white || color == Colors.yellow
                    ? Colors.black
                    : Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildTemplateCard(
    WatermarkTemplate template,
    WatermarkType type,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        _onTemplateSelected(template);
        controller.selectCategory('');
        controller.selectTool('');
      },
      child: Container(
        width: 100.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade800, Colors.grey.shade900],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: _buildTemplatePreview(template, type, index),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: primaryGradient.scale(0.7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Text(
                template.name,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatePreview(
    WatermarkTemplate template,
    WatermarkType type,
    int index,
  ) {
    switch (type) {
      case WatermarkType.avatar:
        return _buildAvatarPreview(template);
      case WatermarkType.stamp:
        return _buildStampPreview(template);
      case WatermarkType.timeLocation:
        return _buildTimeLocationPreview(template, index);
      default:
        return Icon(_getIconForType(type), size: 36.sp, color: Colors.white70);
    }
  }

  Widget _buildAvatarPreview(WatermarkTemplate template) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.asset(
            template.thumbnailPath,
            width: 60.w,
            height: 60.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.blueGrey.withOpacity(0.2),
                  border: Border.all(color: Colors.white70, width: 2.5),
                ),
                child: Icon(Icons.person, size: 30.sp, color: Colors.white70),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStampPreview(WatermarkTemplate template) {
    if (template.thumbnailPath.isNotEmpty) {
      return Image.asset(
        template.thumbnailPath,
        width: 50.w,
        height: 50.w,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withOpacity(0.6),
                  Colors.orange.withOpacity(0.6),
                ],
              ),
              border: Border.all(color: Colors.white70, width: 2),
            ),
            child: Icon(Icons.verified, color: Colors.white, size: 28.sp),
          );
        },
      );
    }

    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.withOpacity(0.6), Colors.orange.withOpacity(0.6)],
        ),
        border: Border.all(color: Colors.white70, width: 2),
      ),
      child: Icon(Icons.verified, color: Colors.white, size: 28.sp),
    );
  }

  Widget _buildTimeLocationPreview(WatermarkTemplate template, int index) {
    switch (index) {
      case 0: // Minimal
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '14:30',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Location',
              style: TextStyle(fontSize: 8.sp, color: Colors.white70),
            ),
            Text(
              '☀️ 22°C',
              style: TextStyle(fontSize: 9.sp, color: Colors.white70),
            ),
          ],
        );
      case 1: // Card
        return Container(
          width: 70.w,
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '14:30',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'City',
                style: TextStyle(fontSize: 7.sp, color: Colors.white70),
              ),
              Text(
                '☀️ 22°',
                style: TextStyle(fontSize: 8.sp, color: Colors.white),
              ),
            ],
          ),
        );
      case 2: // Modern
        return Container(
          width: 70.w,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.6),
                Colors.blue.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '☀️ 14:30',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '📍 Location',
                style: TextStyle(fontSize: 7.sp, color: Colors.white),
              ),
            ],
          ),
        );
      case 3: // Classic
        return Container(
          width: 75.w,
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.white70, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '14:30',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                width: 30.w,
                height: 1,
                color: Colors.white30,
                margin: EdgeInsets.symmetric(vertical: 2.h),
              ),
              Text(
                'Location',
                style: TextStyle(fontSize: 7.sp, color: Colors.white70),
              ),
              Text(
                '☀️ 22°C',
                style: TextStyle(fontSize: 7.sp, color: Colors.white70),
              ),
            ],
          ),
        );
      default:
        return const Icon(Icons.access_time, color: Colors.white70);
    }
  }

  IconData _getIconForType(WatermarkType type) {
    switch (type) {
      case WatermarkType.avatar:
        return Icons.person;
      case WatermarkType.timeLocation:
        return Icons.access_time;
      case WatermarkType.stamp:
        return Icons.verified;
      default:
        return Icons.image;
    }
  }

  void _onTemplateSelected(WatermarkTemplate template) {
    switch (template.type) {
      case WatermarkType.avatar:
        controller.addAvatarWatermark(template);
        break;
      case WatermarkType.timeLocation:
        controller.addTimeLocationWatermark(template);
        break;
      case WatermarkType.stamp:
        _onStampTemplateSelected(template);
        break;
      default:
        break;
    }
  }

  Widget _buildTimeLocationPreviewWidget(WatermarkElement element) {
    final data = element.dynamicData!;
    final time = data['time'] ?? '';
    final date = data['date'] ?? '';
    final location = data['location'] ?? '';
    final weather = data['weather'] ?? '';

    switch (element.templateId) {
      case 'time_location_1': // Minimal
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              location,
              style: TextStyle(
                fontSize: 8.sp,
                color: Colors.white.withOpacity(0.9),
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              weather,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        );

      case 'time_location_2': // Card
        return Container(
          width: 110.w,
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                location,
                style: TextStyle(
                  fontSize: 7.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                weather,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );

      case 'time_location_3': // Modern
        return Container(
          width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.7),
                Colors.blue.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$weather  $time',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '📍 $location',
                style: TextStyle(
                  fontSize: 7.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );

      case 'time_location_4': // Classic
        return Container(
          width: 120.w,
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 6.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Container(
                width: 30.w,
                height: 1,
                color: Colors.white.withOpacity(0.3),
                margin: EdgeInsets.symmetric(vertical: 2.h),
              ),
              Text(
                location,
                style: TextStyle(
                  fontSize: 7.sp,
                  color: Colors.white.withOpacity(0.85),
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                weather,
                style: TextStyle(
                  fontSize: 7.sp,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                location,
                style: TextStyle(fontSize: 10.sp, color: Colors.white70),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                weather,
                style: TextStyle(fontSize: 11.sp, color: Colors.white),
              ),
            ],
          ),
        );
    }
  }

  Future<void> _onTimeLocationTap() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      controller.selectCategory('timeLocation');
      return;
    }

    if (status.isPermanentlyDenied) {
      errorToast('Please enable location permission in app settings');
      await openAppSettings();
      return;
    }

    final granted = await controller.requestLocationPermission();
    if (granted) {
      controller.selectCategory('timeLocation');
    } else {
      errorToast('Location permission is required for this feature');
    }
  }

  void _onStampTemplateSelected(WatermarkTemplate template) {
    controller.addStampWatermark(template, null);
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showTextInputDialog() {
    final element = WatermarkElement.text(
      text: 'Text',
      textColor: Colors.white,
      textSize: 32,
      position: const Offset(100, 100),
    );

    controller.watermarkElements.add(element);
    controller.selectedElementId.value = element.id;
  }

  Widget _buildDrawTools() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.brush, color: primaryColor, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Drawing Tools',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 20.sp),
                onPressed: () => controller.deactivateDrawingMode(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          SizedBox(
            height: 70.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.brushTypes.length,
              itemBuilder: (context, index) {
                final brush = controller.brushTypes[index];
                final brushType = brush['type'] as BrushType;
                final label = brush['label'] as String;
                final icon = brush['icon'] as IconData;

                return Obx(() {
                  final isSelected =
                      controller.selectedBrushType.value == brushType;
                  final isEraser = controller.isEraserMode.value;

                  return GestureDetector(
                    onTap: () => controller.selectBrushType(brushType),
                    child: Container(
                      width: 60.w,
                      margin: EdgeInsets.only(right: 8.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              gradient: isSelected && !isEraser
                                  ? primaryGradient
                                  : null,
                              color: isSelected && !isEraser
                                  ? null
                                  : Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              icon,
                              color: isSelected && !isEraser
                                  ? Colors.white
                                  : Colors.white70,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: isSelected && !isEraser
                                  ? primaryColor
                                  : Colors.white70,
                              fontWeight: isSelected && !isEraser
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          SizedBox(height: 8.h),

          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.drawingColors.length,
              itemBuilder: (context, index) {
                final color = controller.drawingColors[index];
                return Obx(() {
                  final isSelected =
                      controller.selectedDrawingColor.value == color &&
                      !controller.isEraserMode.value;
                  return GestureDetector(
                    onTap: () => controller.selectDrawingColor(color),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : color == const Color(0xFFFFFFFF)
                              ? Colors.grey.shade600
                              : Colors.transparent,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: primaryColor.withOpacity(0.5),
                              blurRadius: 6.r,
                              spreadRadius: 0.5,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                              size: 16.sp,
                            )
                          : null,
                    ),
                  );
                });
              },
            ),
          ),
          SizedBox(height: 8.h),

          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.line_weight, size: 16.sp, color: Colors.white70),
                  SizedBox(width: 8.w),
                  Text(
                    'Width',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2.h,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 6.r,
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: 12.r,
                        ),
                      ),
                      child: Slider(
                        value: controller.brushWidth.value,
                        min: 2,
                        max: 50,
                        activeColor: primaryColor,
                        inactiveColor: Colors.grey.shade600,
                        onChanged: controller.updateBrushWidth,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 28.w,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${controller.brushWidth.value.toInt()}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),

          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildDrawActionButton(
                    Icons.auto_fix_high,
                    'Eraser',
                    controller.isEraserMode.value,
                    controller.toggleEraserMode,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildDrawActionButton(
                  Icons.undo_rounded,
                  'Undo',
                  false,
                  controller.undoLastStroke,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildDrawActionButton(
                  Icons.delete_outline_rounded,
                  'Clear',
                  false,
                  controller.clearAllDrawings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawActionButton(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: BoxDecoration(
          gradient: isActive ? primaryGradient : null,
          color: isActive ? null : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;
  final bool isEraserMode;
  final Offset? eraserPosition;
  final double eraserRadius;

  DrawingPainter({
    required this.strokes,
    this.currentStroke,
    required this.isEraserMode,
    this.eraserPosition,
    required this.eraserRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }

    if (isEraserMode && eraserPosition != null) {
      _drawEraserIndicator(canvas, eraserPosition!);
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.length < 2) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = _getStrokeCap(stroke.brushType)
      ..style = PaintingStyle.stroke;

    switch (stroke.brushType) {
      case BrushType.marker:
        paint.color = stroke.color.withOpacity(0.6);
        paint.strokeCap = StrokeCap.square;
        break;
      case BrushType.highlighter:
        paint.color = stroke.color.withOpacity(0.3);
        break;
      default:
        break;
    }

    final path = Path();
    path.moveTo(stroke.points.first.offset.dx, stroke.points.first.offset.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      final point = stroke.points[i].offset;

      if (stroke.brushType == BrushType.dashed && i > 0) {
        final prevPoint = stroke.points[i - 1].offset;
        final distance = (point - prevPoint).distance;
        if (i % 3 == 0 && distance > 5) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  StrokeCap _getStrokeCap(BrushType type) {
    switch (type) {
      case BrushType.pencil:
      case BrushType.normal:
        return StrokeCap.round;
      case BrushType.marker:
      case BrushType.highlighter:
        return StrokeCap.square;
      case BrushType.dashed:
        return StrokeCap.round;
    }
  }

  void _drawEraserIndicator(Canvas canvas, Offset position) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(position, eraserRadius, paint);

    final crossPaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(position.dx - eraserRadius, position.dy),
      Offset(position.dx + eraserRadius, position.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(position.dx, position.dy - eraserRadius),
      Offset(position.dx, position.dy + eraserRadius),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
