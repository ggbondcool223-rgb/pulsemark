import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../db_pulse_mark/data.dart';
import '../../db_pulse_mark/db_pulse_mark_entity.dart';
import '../../utils/index.dart';
import '../../common/colors.dart';

class HistoryItem {
  final int id;
  final String type;
  final List<String> imagePaths;
  final DateTime createdAt;
  final String? gridMode;

  HistoryItem({
    required this.id,
    required this.type,
    required this.imagePaths,
    required this.createdAt,
    this.gridMode,
  });
}

class PulseMarkHomeLogic extends GetxController {
  final historyItems = <HistoryItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void refreshHistory() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      isLoading.value = true;
      
      final watermarkDao = WatermarkHistoryDao();
      final gridCutDao = GridCutHistoryDao();

      final List<WatermarkHistory> watermarks = await watermarkDao.getAll();
      final List<GridCutHistory> gridCuts = await gridCutDao.getAll();

      final items = <HistoryItem>[];

      for (final wm in watermarks) {
        final paths = wm.imagePath.split(',').where((p) => p.isNotEmpty).toList();
        if (paths.isNotEmpty) {
          items.add(HistoryItem(
            id: wm.id!,
            type: 'watermark',
            imagePaths: paths,
            createdAt: DateTime.parse(wm.createdAt),
          ));
        }
      }

      for (final gc in gridCuts) {
        final paths = gc.getFilePathsList();
        if (paths.isNotEmpty) {
          items.add(HistoryItem(
            id: gc.id!,
            type: 'grid_cut',
            imagePaths: paths,
            createdAt: DateTime.parse(gc.createdAt),
            gridMode: gc.gridMode,
          ));
        }
      }

      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      historyItems.value = items;
    } catch (e) {
      debugPrint('Failed to load history: $e');
      errorToast('Failed to load history');
    } finally {
      isLoading.value = false;
    }
  }

  void onImageTap(String imagePath) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => Get.back(),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 20.w,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.transparent,
    );
  }

  void onGridCutTap(List<String> imagePaths, String gridMode) {
    Get.dialog(
      GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  gridMode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getGridColumns(gridMode),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.back();
                        onImageTap(imagePaths[index]);
                      },
                      child: Image.file(
                        File(imagePaths[index]),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black,
    );
  }

  int _getGridColumns(String gridMode) {
    if (gridMode.contains('9')) return 3;
    if (gridMode.contains('6')) return 3;
    if (gridMode.contains('4')) return 2;
    if (gridMode.contains('3')) return 3;
    return 3;
  }

  Future<void> onDeleteTap(HistoryItem item) async {
    final itemType = item.type == 'watermark' ? 'Watermark' : 'Grid Cut';
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 32.sp,
                  color: Colors.red.shade400,
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                'Delete $itemType?',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: textPrimaryColor,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 12.h),

              Text(
                'This action cannot be undone. The ${item.imagePaths.length} image${item.imagePaths.length > 1 ? 's' : ''} will be permanently deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: textSecondaryColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: textPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        _deleteHistory(item);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade400,
                              Colors.red.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade300.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Delete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _deleteHistory(HistoryItem item) async {
    try {
      for (final path in item.imagePaths) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }

      if (item.type == 'watermark') {
        final dao = WatermarkHistoryDao();
        await dao.delete(item.id);
      } else {
        final dao = GridCutHistoryDao();
        await dao.delete(item.id);
      }

      await loadHistory();
      successToast('Deleted successfully');
    } catch (e) {
      debugPrint('Failed to delete: $e');
      errorToast('Failed to delete');
    }
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
