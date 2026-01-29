import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/colors.dart';
import '../../../components/text_field.dart';
import '../../../models/image_size_preset.dart';

class SizeSelectorDialog extends StatefulWidget {
  final int originalWidth;
  final int originalHeight;

  const SizeSelectorDialog({
    super.key,
    required this.originalWidth,
    required this.originalHeight,
  });

  @override
  State<SizeSelectorDialog> createState() => _SizeSelectorDialogState();
}

class _SizeSelectorDialogState extends State<SizeSelectorDialog> {
  late ImageSizePreset selectedPreset;
  int customWidth = 0;
  int customHeight = 0;
  bool keepAspectRatio = true;

  @override
  void initState() {
    super.initState();
    selectedPreset = ImageSizePreset.original;
    customWidth = widget.originalWidth;
    customHeight = widget.originalHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.8.sh, maxWidth: 0.9.sw),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20.h),
            Flexible(child: _buildPresetList()),
            if (selectedPreset.isCustom) ...[
              SizedBox(height: 20.h),
              _buildCustomInputs(),
            ],
            SizedBox(height: 20.h),
            _buildEstimatedSize(),
            SizedBox(height: 24.h),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Output Size',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Original: ${widget.originalWidth} × ${widget.originalHeight}',
          style: TextStyle(fontSize: 13.sp, color: textSecondaryColor),
        ),
      ],
    );
  }

  Widget _buildPresetList() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: ImageSizePreset.allPresets.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final preset = ImageSizePreset.allPresets[index];
        return _buildPresetItem(preset);
      },
    );
  }

  Widget _buildPresetItem(ImageSizePreset preset) {
    final isSelected = selectedPreset == preset;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPreset = preset;
          if (!preset.isCustom && !preset.isOriginal) {
            customWidth = preset.width ?? widget.originalWidth;
            customHeight = preset.height ?? widget.originalHeight;
          }
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? primaryColor : Colors.grey.shade400,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    preset.getDisplaySize(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomInputs() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Size',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: MyTextField(
                  value: customWidth.toString(),
                  onChange: _onWidthChanged,
                  hintText: 'Width',
                  isInteger: true,
                  textStyle: TextStyle(fontSize: 14.sp),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Icon(
                  Icons.close,
                  size: 16.sp,
                  color: textSecondaryColor,
                ),
              ),
              Expanded(
                child: MyTextField(
                  value: customHeight.toString(),
                  onChange: _onHeightChanged,
                  hintText: 'Height',
                  isInteger: true,
                  textStyle: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Checkbox(
                value: keepAspectRatio,
                onChanged: (value) {
                  setState(() {
                    keepAspectRatio = value ?? true;
                  });
                },
                activeColor: primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              SizedBox(width: 8.w),
              Text(
                'Keep aspect ratio',
                style: TextStyle(fontSize: 13.sp, color: textPrimaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onWidthChanged(String value) {
    final width = int.tryParse(value) ?? 0;
    setState(() {
      customWidth = width;
      if (keepAspectRatio && width > 0) {
        final aspectRatio = widget.originalWidth / widget.originalHeight;
        customHeight = (width / aspectRatio).round();
      }
    });
  }

  void _onHeightChanged(String value) {
    final height = int.tryParse(value) ?? 0;
    setState(() {
      customHeight = height;
      if (keepAspectRatio && height > 0) {
        final aspectRatio = widget.originalWidth / widget.originalHeight;
        customWidth = (height * aspectRatio).round();
      }
    });
  }

  Widget _buildEstimatedSize() {
    final estimatedSize = _calculateEstimatedSize();

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16.sp, color: primaryColor),
          SizedBox(width: 8.w),
          Text(
            'Estimated file size: $estimatedSize',
            style: TextStyle(
              fontSize: 12.sp,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateEstimatedSize() {
    int width, height;

    if (selectedPreset.isOriginal) {
      width = widget.originalWidth;
      height = widget.originalHeight;
    } else if (selectedPreset.isCustom) {
      width = customWidth;
      height = customHeight;
    } else {
      width = selectedPreset.width ?? widget.originalWidth;
      height = selectedPreset.height ?? widget.originalHeight;
    }

    final bytes = (width * height * 3 * 0.3).toInt();
    final mb = bytes / (1024 * 1024);

    if (mb < 1) {
      final kb = bytes / 1024;
      return '~${kb.toStringAsFixed(0)} KB';
    } else {
      return '~${mb.toStringAsFixed(1)} MB';
    }
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Get.back(result: null),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 15.sp,
              color: textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        ElevatedButton(
          onPressed: _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
          child: Text(
            'Confirm',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _onConfirm() {
    int? targetWidth;
    int? targetHeight;

    if (selectedPreset.isOriginal) {
      targetWidth = null;
      targetHeight = null;
    } else if (selectedPreset.isCustom) {
      if (customWidth <= 0 || customHeight <= 0) {
        Get.snackbar(
          'Invalid Size',
          'Please enter valid width and height',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      targetWidth = customWidth;
      targetHeight = customHeight;
    } else {
      targetWidth = selectedPreset.width;
      targetHeight = selectedPreset.height;
    }

    if (targetWidth != null && targetHeight != null) {
      if (targetWidth > 10000 || targetHeight > 10000) {
        Get.snackbar(
          'Size Too Large',
          'Maximum size is 10000 × 10000',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      if (targetWidth < 100 || targetHeight < 100) {
        Get.snackbar(
          'Size Too Small',
          'Minimum size is 100 × 100',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
    }

    Get.back(result: {'width': targetWidth, 'height': targetHeight});
  }
}
