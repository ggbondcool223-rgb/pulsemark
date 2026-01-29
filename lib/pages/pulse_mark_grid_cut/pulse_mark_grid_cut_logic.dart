import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulse_mark/utils/index.dart';
import '../../db_pulse_mark/data.dart';
import '../../db_pulse_mark/db_pulse_mark_entity.dart';
import '../pulse_mark_home/pulse_mark_home_logic.dart';

class PulseMarkGridCutLogic extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString savingProgress = ''.obs;
  final Rx<ui.Image?> uiImage = Rx<ui.Image?>(null);
  final RxList<Rect> gridRects = <Rect>[].obs;

  final RxInt rows = 3.obs;
  final RxInt cols = 3.obs;
  final RxString currentMode = '9 Grid'.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 300), () {
      onSelectPhoto();
    });
  }

  Future<void> onSelectPhoto() async {
    try {
      if (selectedImage.value != null) {
        final shouldReplace = await Get.dialog<bool>(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF13ec37), Color(0xFF0bc42f)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Replace Photo?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your current photo and grid settings will be replaced.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(result: false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(
                              color: Color(0xFFE0E0E0),
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF13ec37), Color(0xFF0bc42f)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF13ec37,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Get.back(result: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Replace',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
        );

        if (shouldReplace != true) return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        isLoading.value = true;
        final file = File(pickedFile.path);
        await _loadImage(file);
      } else {
        if (selectedImage.value == null) {
          Get.back();
        }
      }
    } catch (e) {
      errorToast('Failed to select image: ${e.toString()}');
      if (selectedImage.value == null) {
        Get.back();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadImage(File file) async {
    try {
      final bytes = await file.readAsBytes();

      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      if (decodedImage.width < 300 || decodedImage.height < 300) {
        errorToast('Image is too small (min 300x300px)');
        return;
      }

      if (decodedImage.width < 900 || decodedImage.height < 900) {
        errorToast('Image is small, quality may be low');
      }

      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) {
        errorToast('Image too large, may cause issues');
      }

      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();

      selectedImage.value = file;
      uiImage.value = frameInfo.image;

      _calculateGrids(frameInfo.image);

      successToast('Image loaded successfully');
    } catch (e) {
      errorToast('Failed to load image: ${e.toString()}');
      _clearImage();
    }
  }

  void _calculateGrids(ui.Image image) {
    final gridWidth = image.width / cols.value;
    final gridHeight = image.height / rows.value;

    gridRects.clear();
    for (int row = 0; row < rows.value; row++) {
      for (int col = 0; col < cols.value; col++) {
        gridRects.add(
          Rect.fromLTWH(
            col * gridWidth,
            row * gridHeight,
            gridWidth,
            gridHeight,
          ),
        );
      }
    }
  }

  void changeGridMode(String mode) {
    if (uiImage.value == null) return;

    switch (mode) {
      case '9 Grid':
        rows.value = 3;
        cols.value = 3;
        currentMode.value = '9 Grid';
        break;
      case '6 Grid':
        rows.value = 2;
        cols.value = 3;
        currentMode.value = '6 Grid';
        break;
      case '4 Grid':
        rows.value = 2;
        cols.value = 2;
        currentMode.value = '4 Grid';
        break;
      case '3 Grid':
        rows.value = 1;
        cols.value = 3;
        currentMode.value = '3 Grid';
        break;
    }

    _calculateGrids(uiImage.value!);
  }

  Future<void> onSaveAll() async {
    if (selectedImage.value == null) {
      errorToast('Please select a photo first');
      return;
    }

    try {
      final status = await _requestPhotoPermission();
      if (!status) {
        errorToast('Album permission required');
        return;
      }

      isSaving.value = true;

      final bytes = await selectedImage.value!.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      final gridWidth = (originalImage.width / cols.value).floor();
      final gridHeight = (originalImage.height / rows.value).floor();

      final documentsDir = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      int successCount = 0;
      int failCount = 0;
      final savedPaths = <String>[];

      final totalCount = rows.value * cols.value;

      for (int row = 0; row < rows.value; row++) {
        for (int col = 0; col < cols.value; col++) {
          final index = row * cols.value + col;
          savingProgress.value = 'Saving ${index + 1}/$totalCount...';

          try {
            final croppedImage = img.copyCrop(
              originalImage,
              x: col * gridWidth,
              y: row * gridHeight,
              width: gridWidth,
              height: gridHeight,
            );

            final jpegBytes = img.encodeJpg(croppedImage, quality: 95);

            final filename = 'grid_cut_${timestamp}_${index + 1}.jpg';
            final documentsFile = File('${documentsDir.path}/$filename');
            await documentsFile.writeAsBytes(jpegBytes);
            savedPaths.add(documentsFile.path);

            final tempFile = File('${tempDir.path}/$filename');
            await tempFile.writeAsBytes(jpegBytes);

            final result = await ImageGallerySaverPlus.saveFile(
              tempFile.path,
              name: filename,
            );

            if (result['isSuccess'] == true) {
              successCount++;
            } else {
              failCount++;
            }

            if (await tempFile.exists()) {
              await tempFile.delete();
            }
          } catch (e) {
            failCount++;
            debugPrint('Failed to save grid ${index + 1}: $e');
          }
        }
      }

      if (savedPaths.isNotEmpty) {
        final dao = GridCutHistoryDao();
        final history = GridCutHistory(
          timestamp: timestamp.toString(),
          gridMode: currentMode.value,
          rows: rows.value,
          cols: cols.value,
          filePaths: jsonEncode(savedPaths),
          createdAt: DateTime.now().toIso8601String(),
        );
        await dao.insert(history);
      }

      try {
        final homeLogic = Get.find<PulseMarkHomeLogic>();
        homeLogic.refreshHistory();
      } catch (e) {
        debugPrint('Failed to refresh home: $e');
      }

      if (failCount == 0) {
        successToast('$totalCount photos saved to album');

        _showCompletionDialog(totalCount);
      } else {
        errorToast('$successCount/$totalCount saved, $failCount failed');
      }
    } catch (e) {
      errorToast('Failed to save: ${e.toString()}');
    } finally {
      isSaving.value = false;
      savingProgress.value = '';
    }
  }

  Future<bool> _requestPhotoPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    } else if (Platform.isAndroid) {
      if (await Permission.photos.isGranted) {
        return true;
      }
      final status = await Permission.photos.request();
      if (status.isGranted) {
        return true;
      }

      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
    return true;
  }

  void _showCompletionDialog(int totalCount) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF13ec37), Color(0xFF0bc42f)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF13ec37).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Save Completed!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$totalCount photos have been saved to your album.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'What\'s next?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF13ec37), Color(0xFF0bc42f)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF13ec37).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _clearImage();
                        onSelectPhoto(); // 选择新图片
                      },
                      icon: const Icon(Icons.add_photo_alternate, size: 20),
                      label: const Text(
                        'Choose Another Photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        Get.back(); // 返回首页
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
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
    );
  }

  void _clearImage() {
    selectedImage.value = null;
    uiImage.value = null;
    gridRects.clear();
    rows.value = 3;
    cols.value = 3;
    currentMode.value = '9 Grid';
  }

  @override
  void onClose() {
    uiImage.value?.dispose();
    super.onClose();
  }
}
