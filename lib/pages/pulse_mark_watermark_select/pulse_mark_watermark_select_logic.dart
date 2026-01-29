import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/index.dart';

class PhotoAssetModel {
  final AssetEntity? asset;
  final String? filePath;
  final Uint8List? thumbnail;

  PhotoAssetModel({this.asset, this.filePath, this.thumbnail})
    : assert(
        asset != null || filePath != null,
        'Either asset or filePath must be provided',
      );

  bool get isCaptured => filePath != null;
  String get id => asset?.id ?? filePath!;
}

class PulseMarkWatermarkSelectLogic extends GetxController {
  final selectedPhotos = <dynamic>[].obs;
  final photos = <PhotoAssetModel>[].obs;
  final capturedPhotos = <PhotoAssetModel>[].obs;
  final isLoading = false.obs;
  final maxPhotos = 20;

  int get selectedCount => selectedPhotos.length;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => _requestPermissionAndLoadPhotos());
  }

  Future<void> _requestPermissionAndLoadPhotos() async {
    try {
      isLoading.value = true;

      final PermissionState ps = await PhotoManager.requestPermissionExtend();

      if (ps.isAuth || ps.hasAccess) {
        await _loadPhotos();
      } else {
        isLoading.value = false;
        errorToast(
          'Photos permission denied. Please grant permission in settings.',
        );

        await Future.delayed(const Duration(seconds: 1));
        PhotoManager.openSetting();
      }
    } catch (e) {
      isLoading.value = false;
      errorToast('Failed to load photos: ${e.toString()}');
      print('Error loading photos: $e');
    }
  }

  Future<void> _loadPhotos() async {
    try {
      isLoading.value = true;

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );

      if (paths.isEmpty) {
        errorToast('No photos found');
        return;
      }

      await _loadRecentPhotos(paths[0]);
    } catch (e) {
      errorToast('Failed to load photos: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadRecentPhotos(AssetPathEntity path) async {
    try {
      isLoading.value = true;

      final int count = await path.assetCountAsync;
      final List<AssetEntity> assets = await path.getAssetListRange(
        start: 0,
        end: count > 1000 ? 1000 : count,
      );

      photos.clear();
      for (final asset in assets) {
        final thumbnail = await asset.thumbnailDataWithSize(
          const ThumbnailSize(200, 200),
        );
        photos.add(PhotoAssetModel(asset: asset, thumbnail: thumbnail));
      }
    } catch (e) {
      errorToast('Failed to load photos: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void togglePhoto(dynamic photoIdentifier) {
    if (isPhotoSelected(photoIdentifier)) {
      selectedPhotos.removeWhere((item) {
        if (item is AssetEntity && photoIdentifier is AssetEntity) {
          return item.id == photoIdentifier.id;
        }
        return item == photoIdentifier;
      });
    } else {
      if (selectedPhotos.length < maxPhotos) {
        selectedPhotos.add(photoIdentifier);
      } else {
        errorToast('Maximum $maxPhotos photos allowed');
      }
    }
  }

  bool isPhotoSelected(dynamic photoIdentifier) {
    if (photoIdentifier is AssetEntity) {
      return selectedPhotos.any(
        (item) => item is AssetEntity && item.id == photoIdentifier.id,
      );
    } else if (photoIdentifier is String) {
      return selectedPhotos.contains(photoIdentifier);
    }
    return false;
  }

  void clearSelection() {
    selectedPhotos.clear();
  }

  void clearAll() {
    if (selectedPhotos.isEmpty) {
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Clear All'),
        content: Text('Remove all ${selectedPhotos.length} selected photos?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final count = selectedPhotos.length;
              selectedPhotos.clear();
              Get.back();
              successToast('$count photo${count > 1 ? 's' : ''} cleared');
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void removePhotoAt(int index) {
    if (index >= 0 && index < selectedPhotos.length) {
      selectedPhotos.removeAt(index);
    }
  }

  Future<void> openCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxWidth: 4000,
        maxHeight: 4000,
      );

      if (photo != null) {
        successToast('Photo captured');

        final filePath = photo.path;
        final file = File(filePath);
        final bytes = await file.readAsBytes();

        final newPhotoModel = PhotoAssetModel(
          filePath: filePath,
          thumbnail: bytes,
        );

        capturedPhotos.insert(0, newPhotoModel);

        if (selectedPhotos.length < maxPhotos) {
          selectedPhotos.add(filePath);
          successToast('Photo captured and selected');
        } else {
          successToast('Photo captured (selection limit reached)');
        }
      }
    } catch (e) {
      errorToast('Failed to open camera: ${e.toString()}');
    }
  }

  Future<void> refreshPhotos() async {
    try {
      await _loadPhotos();
      successToast('Photos refreshed');
    } catch (e) {
      errorToast('Failed to refresh: ${e.toString()}');
    }
  }

  void onNextTap() {
    if (selectedPhotos.isEmpty) {
      errorToast('Please select at least one photo');
      return;
    }

    try {
      Get.toNamed(
        '/pulse_mark_watermark_edit',
        arguments: {'photos': selectedPhotos.toList()},
      );
    } catch (e) {
      errorToast('Failed to proceed: ${e.toString()}');
    }
  }
}
