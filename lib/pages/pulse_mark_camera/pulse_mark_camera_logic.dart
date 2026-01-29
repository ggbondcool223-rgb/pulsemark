import 'dart:io';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/index.dart';

class PulseMarkCameraLogic extends GetxController {
  CameraController? cameraController;
  final isCameraInitialized = false.obs;
  final isLoading = true.obs;
  final isTakingPicture = false.obs;

  List<CameraDescription> cameras = [];
  final currentCameraIndex = 0.obs;

  final capturedPhotoPath = Rxn<String>();

  File? get capturedPhoto =>
      capturedPhotoPath.value != null ? File(capturedPhotoPath.value!) : null;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  Future<void> _initializeCamera() async {
    try {
      isLoading.value = true;

      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        errorToast('Camera permission is required');
        Get.back();
        return;
      }

      cameras = await availableCameras();

      if (cameras.isEmpty) {
        errorToast('No camera found');
        Get.back();
        return;
      }

      await _setupCamera(currentCameraIndex.value);
    } catch (e) {
      errorToast('Failed to initialize camera: ${e.toString()}');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (cameras.isEmpty) return;

    await cameraController?.dispose();

    cameraController = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      errorToast('Failed to initialize camera: ${e.toString()}');
      isCameraInitialized.value = false;
    }
  }

  Future<void> onSwitchCameraTap() async {
    if (cameras.length < 2) {
      errorToast('Only one camera available');
      return;
    }

    currentCameraIndex.value = (currentCameraIndex.value + 1) % cameras.length;
    isCameraInitialized.value = false;
    await _setupCamera(currentCameraIndex.value);
  }

  Future<void> onTakePictureTap() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      errorToast('Camera is not ready');
      return;
    }

    if (isTakingPicture.value) return;

    try {
      isTakingPicture.value = true;

      final XFile photo = await cameraController!.takePicture();
      capturedPhotoPath.value = photo.path;

      await cameraController?.pausePreview();
    } catch (e) {
      errorToast('Failed to take picture: ${e.toString()}');
    } finally {
      isTakingPicture.value = false;
    }
  }

  Future<void> onRetakeTap() async {
    capturedPhotoPath.value = null;

    try {
      await cameraController?.resumePreview();
    } catch (e) {
      errorToast('Failed to resume camera: ${e.toString()}');
    }
  }

  void onUseTap() {
    if (capturedPhotoPath.value == null) {
      errorToast('No photo captured');
      return;
    }

    try {
      Get.offNamed(
        '/pulse_mark_watermark_edit',
        arguments: {
          'photos': [capturedPhotoPath.value],
        },
      );
    } catch (e) {
      errorToast('Failed to proceed: ${e.toString()}');
    }
  }

  Future<void> onSelectFromAlbumTap() async {
    try {
      await cameraController?.pausePreview();

      final photoStatus = await Permission.photos.request();
      if (!photoStatus.isGranted) {
        errorToast('Photo library permission is required');
        await cameraController?.resumePreview();
        return;
      }

      final picker = await Get.toNamed('/select_photo_from_album');

      if (picker != null) {
        capturedPhotoPath.value = picker;
      } else {
        await cameraController?.resumePreview();
      }
    } catch (e) {
      errorToast('Failed to select photo: ${e.toString()}');
      await cameraController?.resumePreview();
    }
  }
}
