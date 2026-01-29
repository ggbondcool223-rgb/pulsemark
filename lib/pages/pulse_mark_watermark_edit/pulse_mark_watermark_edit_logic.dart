import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/index.dart';
import '../../utils/watermark_painter.dart';
import '../../models/watermark_element.dart';
import '../../services/location_service.dart';
import '../../services/weather_service.dart';
import '../../db_pulse_mark/data.dart';
import '../../db_pulse_mark/db_pulse_mark_entity.dart';
import '../pulse_mark_home/pulse_mark_home_logic.dart';
import 'widgets/size_selector_dialog.dart';

enum BrushType { normal, dashed, pencil, marker, highlighter }

class DrawingPoint {
  final Offset offset;
  final double pressure;

  DrawingPoint({required this.offset, this.pressure = 1.0});
}

class DrawingStroke {
  final String id;
  final List<DrawingPoint> points;
  final Color color;
  final double width;
  final BrushType brushType;
  final DateTime timestamp;

  DrawingStroke({
    required this.id,
    required this.points,
    required this.color,
    required this.width,
    required this.brushType,
    required this.timestamp,
  });

  bool containsPoint(Offset point, double radius) {
    for (final drawPoint in points) {
      final distance = (drawPoint.offset - point).distance;
      if (distance <= radius + width / 2) {
        return true;
      }
    }
    return false;
  }
}

class PulseMarkWatermarkEditLogic extends GetxController {
  final photos = <dynamic>[].obs;
  final photoDataList = <Uint8List>[].obs;
  final currentPhotoIndex = 0.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  Uint8List? get currentPhotoData =>
      photoDataList.isNotEmpty && currentPhotoIndex.value < photoDataList.length
      ? photoDataList[currentPhotoIndex.value]
      : null;

  final displayedImageSize = Rxn<Size>();
  Size? calculatedImageSize;
  Size? _lastContainerSize;

  final watermarkElements = <WatermarkElement>[].obs;
  final selectedElementId = Rxn<String>();

  WatermarkElement? get selectedElement => watermarkElements.firstWhereOrNull(
    (e) => e.id == selectedElementId.value,
  );

  final undoStack = <List<WatermarkElement>>[].obs;
  final redoStack = <List<WatermarkElement>>[].obs;

  final selectedTool = ''.obs;
  final selectedCategory = ''.obs;

  final drawingStrokes = <DrawingStroke>[].obs;
  DrawingStroke? currentStroke;
  final isDrawingMode = false.obs;
  final selectedDrawingColor = const Color(0xFFFF4081).obs;
  final selectedBrushType = BrushType.normal.obs;
  final brushWidth = 5.0.obs;
  final isEraserMode = false.obs;
  final eraserRadius = 20.0.obs;
  Offset? eraserPosition;
  final drawingUpdateTrigger = 0.obs;

  final List<Color> drawingColors = const [
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFFFF4081),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
    Color(0xFF00BCD4),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
    Color(0xFFFFEB3B),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
    Color(0xFF795548),
    Color(0xFF9E9E9E),
  ];

  final List<Map<String, dynamic>> brushTypes = const [
    {'type': BrushType.normal, 'label': 'Normal', 'icon': Icons.brush},
    {'type': BrushType.dashed, 'label': 'Dashed', 'icon': Icons.line_style},
    {'type': BrushType.pencil, 'label': 'Pencil', 'icon': Icons.edit},
    {'type': BrushType.marker, 'label': 'Marker', 'icon': Icons.create},
    {
      'type': BrushType.highlighter,
      'label': 'Highlight',
      'icon': Icons.highlight,
    },
  ];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadPhotoFromArguments();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> _loadPhotoFromArguments() async {
    try {
      isLoading.value = true;
      final args = Get.arguments as Map<String, dynamic>?;

      if (args != null && args['photos'] != null) {
        final photosList = args['photos'] as List<dynamic>;

        if (photosList.isEmpty) {
          errorToast('No photos selected');
          Get.back();
          return;
        }

        photos.value = photosList;
        photoDataList.clear();

        for (final photo in photosList) {
          Uint8List? data;

          if (photo is AssetEntity) {
            data = await photo.originBytes;
          } else if (photo is String) {
            final file = File(photo);
            if (await file.exists()) {
              data = await file.readAsBytes();
            }
          }

          if (data != null) {
            photoDataList.add(data);
          }
        }

        if (photoDataList.isEmpty) {
          errorToast('Failed to load photos');
          Get.back();
        } else {
          _saveState();
        }
      } else {
        errorToast('No photos selected');
        Get.back();
      }
    } catch (e) {
      errorToast('Failed to load photos: ${e.toString()}');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  void _saveState() {
    final state = watermarkElements.map((e) => e).toList();
    undoStack.add(state);
    redoStack.clear();

    if (undoStack.length > 50) {
      undoStack.removeAt(0);
    }
  }

  void undo() {
    if (undoStack.length <= 1) {
      errorToast('Nothing to undo');
      return;
    }

    final currentState = undoStack.removeLast();
    redoStack.add(currentState);

    final previousState = undoStack.last;
    watermarkElements.value = previousState.map((e) => e).toList();

    successToast('Undo');
  }

  void redo() {
    if (redoStack.isEmpty) {
      errorToast('Nothing to redo');
      return;
    }

    final state = redoStack.removeLast();
    undoStack.add(state);
    watermarkElements.value = state.map((e) => e).toList();

    successToast('Redo');
  }


  void selectTool(String tool) {
    selectedTool.value = tool;
    selectedCategory.value = '';
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<void> addAvatarWatermark(WatermarkTemplate template) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) {
        errorToast('No avatar selected');
        return;
      }

      final element = WatermarkElement.avatar(
        templateId: template.id,
        templatePath: template.thumbnailPath,
        userAvatarPath: image.path,
        position: const Offset(100, 100),
      );

      watermarkElements.add(element);
      selectedElementId.value = element.id;
      _saveState();
      successToast('Avatar watermark added');
    } catch (e) {
      errorToast('Failed to add avatar: ${e.toString()}');
    }
  }

  Future<void> addTimeLocationWatermark(WatermarkTemplate template) async {
    try {
      isLoading.value = true;

      final now = DateTime.now();
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      print('Fetching location info...');
      final locationInfo = await LocationService.getLocationInfo();
      print('Location info: $locationInfo');

      String location = 'Unknown Location';
      double latitude = 0.0;
      double longitude = 0.0;

      if (locationInfo['success'] == true) {
        location = locationInfo['location'] ?? 'Unknown Location';
        latitude = locationInfo['latitude'] ?? 0.0;
        longitude = locationInfo['longitude'] ?? 0.0;
        print('Location obtained: $location ($latitude, $longitude)');
      } else {
        print('Location failed: ${locationInfo['error'] ?? 'Unknown error'}');
        errorToast('Location not available. Using default.');
      }

      print('Fetching weather for coords: $latitude, $longitude');
      final weatherData = await WeatherService.getWeatherByCoords(
        latitude,
        longitude,
      );
      print('Weather data: $weatherData');

      final weatherText = WeatherService.getWeatherText(weatherData);
      print('Weather text: $weatherText');

      final element = WatermarkElement.timeLocation(
        templateId: template.id,
        templatePath: template.thumbnailPath,
        dynamicData: {
          'time': timeStr,
          'date': dateStr,
          'location': location,
          'weather': weatherText,
          'temperature': weatherData['temperature'] ?? 0,
          'weatherIcon': weatherData['weatherIcon'] ?? '01d',
        },
        position: const Offset(100, 100),
      );

      watermarkElements.add(element);
      selectedElementId.value = element.id;
      _saveState();

      if (locationInfo['success'] == true) {
        successToast('Time/Location watermark added');
      } else {
        successToast('Watermark added (location unavailable)');
      }
    } catch (e) {
      print('Error in addTimeLocationWatermark: $e');
      errorToast('Failed to add watermark: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void addStampWatermark(WatermarkTemplate template, String? text) {
    final element = WatermarkElement.stamp(
      templateId: template.id,
      templatePath: template.thumbnailPath,
      position: const Offset(100, 100),
      stampText: text,
    );

    watermarkElements.add(element);
    selectedElementId.value = element.id;
    _saveState();

    if (text != null && text.isNotEmpty) {
      successToast('Stamp with text added');
    } else {
      successToast('Stamp watermark added');
    }
  }

  Future<void> addCustomImageWatermark() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) {
        errorToast('No image selected');
        return;
      }

      final element = WatermarkElement.customImage(
        imagePath: image.path,
        position: const Offset(100, 100),
      );

      watermarkElements.add(element);
      selectedElementId.value = element.id;
      _saveState();
      successToast('Custom watermark added');
    } catch (e) {
      errorToast('Failed to add custom image: ${e.toString()}');
    }
  }

  void selectElement(String? elementId) {
    selectedElementId.value = elementId;
  }

  void updateElementPosition(String elementId, Offset delta) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      final element = watermarkElements[index];
      watermarkElements[index] = element.copyWith(
        position: element.position + delta,
      );
    }
  }

  void deleteElement(String elementId) {
    watermarkElements.removeWhere((e) => e.id == elementId);
    if (selectedElementId.value == elementId) {
      selectedElementId.value = null;
    }
    _saveState();
    successToast('Watermark deleted');
  }

  void updateElementOpacity(String elementId, double opacity) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      watermarkElements[index] = watermarkElements[index].copyWith(
        opacity: opacity,
      );
    }
  }

  void updateElementScale(String elementId, Offset delta) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      final element = watermarkElements[index];
      final scaleChange = (delta.dx + delta.dy) * 0.01;
      final newScale = (element.scale + scaleChange).clamp(0.3, 3.0);

      watermarkElements[index] = element.copyWith(scale: newScale);
    }
  }

  void updateElementScaleValue(String elementId, double scale) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      watermarkElements[index] = watermarkElements[index].copyWith(
        scale: scale.clamp(0.3, 3.0),
      );
    }
  }

  void updateStampText(String elementId, String text) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      watermarkElements[index] = watermarkElements[index].copyWith(
        stampText: text,
      );
    }
  }

  void updateStampTextColor(String elementId, Color color) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      watermarkElements[index] = watermarkElements[index].copyWith(
        stampTextColor: color,
      );
    }
  }

  void updateStampTextSize(String elementId, double size) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      watermarkElements[index] = watermarkElements[index].copyWith(
        stampTextSize: size,
      );
    }
  }

  void updateStampTextVertical(String elementId, bool isVertical) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      watermarkElements[index] = watermarkElements[index].copyWith(
        stampTextVertical: isVertical,
      );
    }
  }

  void updateTextContent(String elementId, String text) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      watermarkElements[index] = watermarkElements[index].copyWith(text: text);
    }
  }

  void updateTextSize(String elementId, double size) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      watermarkElements[index] = watermarkElements[index].copyWith(
        textSize: size,
      );
    }
  }

  void updateTextColor(String elementId, Color color) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      watermarkElements[index] = watermarkElements[index].copyWith(
        textColor: color,
      );
    }
  }

  void updateTextBold(String elementId, bool isBold) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      watermarkElements[index] = watermarkElements[index].copyWith(
        isBold: isBold,
      );
    }
  }

  void updateTextItalic(String elementId, bool isItalic) {
    final index = watermarkElements.indexWhere((e) => e.id == elementId);
    if (index != -1) {
      watermarkElements[index] = watermarkElements[index].copyWith(
        isItalic: isItalic,
      );
    }
  }


  void previousPhoto() {
    if (currentPhotoIndex.value > 0) {
      currentPhotoIndex.value--;
      _lastContainerSize = null; // Reset to recalculate image size
    }
  }

  void nextPhoto() {
    if (currentPhotoIndex.value < photoDataList.length - 1) {
      currentPhotoIndex.value++;
      _lastContainerSize = null; // Reset to recalculate image size
    }
  }

  bool get hasPreviousPhoto => currentPhotoIndex.value > 0;
  bool get hasNextPhoto => currentPhotoIndex.value < photoDataList.length - 1;

  void updateContainerSize(Size containerSize) {
    if (currentPhotoData == null) return;

    if (_lastContainerSize != null &&
        _lastContainerSize!.width == containerSize.width &&
        _lastContainerSize!.height == containerSize.height) {
      return;
    }

    _lastContainerSize = containerSize;

    try {
      final image = img.decodeImage(currentPhotoData!);
      if (image == null) return;

      final imageAspectRatio = image.width / image.height;
      final containerAspectRatio = containerSize.width / containerSize.height;

      print('Container size: ${containerSize.width} x ${containerSize.height}');
      print(
        'Image aspect ratio: $imageAspectRatio, Container aspect ratio: $containerAspectRatio',
      );

      if (imageAspectRatio > containerAspectRatio) {
        calculatedImageSize = Size(
          containerSize.width,
          containerSize.width / imageAspectRatio,
        );
        print(
          'Image is wider, calculated size: ${calculatedImageSize!.width} x ${calculatedImageSize!.height}',
        );
      } else {
        calculatedImageSize = Size(
          containerSize.height * imageAspectRatio,
          containerSize.height,
        );
        print(
          'Image is taller, calculated size: ${calculatedImageSize!.width} x ${calculatedImageSize!.height}',
        );
      }

      displayedImageSize.value = calculatedImageSize;
    } catch (e) {
      print('Error calculating image size: $e');
    }
  }

  void startDrawing(Offset localPosition) {
    if (!isDrawingMode.value) return;

    if (isEraserMode.value) {
      eraserPosition = localPosition;
      _eraseAtPoint(localPosition);
      drawingUpdateTrigger.value++;
    } else {
      currentStroke = DrawingStroke(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        points: [DrawingPoint(offset: localPosition)],
        color: selectedDrawingColor.value,
        width: brushWidth.value,
        brushType: selectedBrushType.value,
        timestamp: DateTime.now(),
      );
      drawingUpdateTrigger.value++;
    }
  }

  void updateDrawing(Offset localPosition) {
    if (!isDrawingMode.value) return;

    if (isEraserMode.value) {
      eraserPosition = localPosition;
      _eraseAtPoint(localPosition);
      drawingUpdateTrigger.value++;
    } else if (currentStroke != null) {
      currentStroke!.points.add(DrawingPoint(offset: localPosition));
      drawingUpdateTrigger.value++;
    }
  }

  void endDrawing() {
    if (currentStroke != null && currentStroke!.points.length > 1) {
      drawingStrokes.add(currentStroke!);
      currentStroke = null;
      _saveState();
    }
    eraserPosition = null;
    drawingUpdateTrigger.value++;
  }

  void _eraseAtPoint(Offset point) {
    final countBefore = drawingStrokes.length;
    drawingStrokes.removeWhere(
      (stroke) => stroke.containsPoint(point, eraserRadius.value),
    );
    if (drawingStrokes.length != countBefore) {
      _saveState();
      drawingUpdateTrigger.value++;
    }
  }

  void undoLastStroke() {
    if (drawingStrokes.isNotEmpty) {
      drawingStrokes.removeLast();
      _saveState();
      drawingUpdateTrigger.value++;
      successToast('Undo stroke');
    }
  }

  void clearAllDrawings() {
    if (drawingStrokes.isEmpty) return;
    drawingStrokes.clear();
    currentStroke = null;
    _saveState();
    drawingUpdateTrigger.value++;
    successToast('All drawings cleared');
  }

  void selectDrawingColor(Color color) {
    selectedDrawingColor.value = color;
    if (isEraserMode.value) {
      isEraserMode.value = false;
    }
  }

  void selectBrushType(BrushType type) {
    selectedBrushType.value = type;
    switch (type) {
      case BrushType.pencil:
        brushWidth.value = 2.0;
        break;
      case BrushType.marker:
      case BrushType.highlighter:
        brushWidth.value = 15.0;
        break;
      default:
        brushWidth.value = 5.0;
    }
    if (isEraserMode.value) {
      isEraserMode.value = false;
    }
  }

  void updateBrushWidth(double width) {
    brushWidth.value = width;
  }

  void toggleEraserMode() {
    isEraserMode.value = !isEraserMode.value;
  }

  void activateDrawingMode() {
    isDrawingMode.value = true;
    selectedCategory.value = '';
    selectedElementId.value = null;
  }

  void deactivateDrawingMode() {
    isDrawingMode.value = false;
    isEraserMode.value = false;
    currentStroke = null;
    eraserPosition = null;
  }


  Future<void> onSaveTap() async {
    if (isSaving.value) return;

    if (watermarkElements.isEmpty) {
      errorToast('Please add at least one watermark');
      return;
    }

    final sizeResult = await _showSizeSelectorDialog();
    if (sizeResult == null) {
      return;
    }

    final targetWidth = sizeResult['width'];
    final targetHeight = sizeResult['height'];

    await _saveWithSize(targetWidth, targetHeight);
  }

  Future<Map<String, int?>?> _showSizeSelectorDialog() async {
    final image = img.decodeImage(photoDataList[0]);
    if (image == null) return null;

    return await Get.dialog<Map<String, int?>>(
      SizeSelectorDialog(
        originalWidth: image.width,
        originalHeight: image.height,
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _saveWithSize(int? targetWidth, int? targetHeight) async {
    try {
      isSaving.value = true;

      selectedElementId.value = null;

      final directory = await getApplicationDocumentsDirectory();
      final savedCount = photoDataList.length;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savedPaths = <String>[];

      for (int i = 0; i < photoDataList.length; i++) {
        currentPhotoIndex.value = i;

        final imageData = await _generateWatermarkedImage(
          photoDataList[i],
          targetWidth: targetWidth,
          targetHeight: targetHeight,
        );
        if (imageData == null) {
          continue;
        }

        final filename = 'watermark_${timestamp}_$i.png';
        final filePath = '${directory.path}/$filename';
        final file = File(filePath);
        await file.writeAsBytes(imageData);
        savedPaths.add(filePath);

        final result = await ImageGallerySaverPlus.saveFile(filePath);
        if (result['isSuccess'] != true) {
          errorToast('Failed to save photo $i to gallery');
        }
      }

      if (savedPaths.isNotEmpty) {
        final dao = WatermarkHistoryDao();
        final history = WatermarkHistory(
          imagePath: savedPaths.join(','), // Multiple paths separated by comma
          watermarkText: '',
          createdAt: DateTime.now().toIso8601String(),
        );
        await dao.insert(history);
      }

      successToast(
        '$savedCount photo${savedCount > 1 ? 's' : ''} saved to gallery',
      );

      try {
        final homeLogic = Get.find<PulseMarkHomeLogic>();
        homeLogic.refreshHistory();
      } catch (e) {
        debugPrint('Failed to refresh home: $e');
      }

      Get.back();
      Get.back();
    } catch (e) {
      errorToast('Failed to save: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  Future<Uint8List?> _generateWatermarkedImage(
    Uint8List photoData, {
    int? targetWidth,
    int? targetHeight,
  }) async {
    try {
      final originalImage = img.decodeImage(photoData);
      if (originalImage == null) return null;

      img.Image processedImage = originalImage;

      if (targetWidth != null && targetHeight != null) {
        processedImage = img.copyResize(
          originalImage,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
        print('Resized to: $targetWidth × $targetHeight');
      } else if (targetWidth != null) {
        processedImage = img.copyResize(
          originalImage,
          width: targetWidth,
          interpolation: img.Interpolation.linear,
        );
        print('Resized to width: $targetWidth');
      } else if (targetHeight != null) {
        processedImage = img.copyResize(
          originalImage,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
        print('Resized to height: $targetHeight');
      } else {
        print('Using original size: ${originalImage.width} × ${originalImage.height}');
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(
        processedImage.width.toDouble(),
        processedImage.height.toDouble(),
      );

      final imageBytes = img.encodePng(processedImage);
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      canvas.drawImage(image, Offset.zero, Paint());

      double scaleX = 1.0;
      double scaleY = 1.0;

      if (displayedImageSize.value != null) {
        scaleX = processedImage.width / displayedImageSize.value!.width;
        scaleY = processedImage.height / displayedImageSize.value!.height;
        print(
          'Processed image size: ${processedImage.width} x ${processedImage.height}',
        );
        print(
          'Displayed image size: ${displayedImageSize.value!.width} x ${displayedImageSize.value!.height}',
        );
        print('Coordinate scale: $scaleX x $scaleY');
      } else {
        print('Warning: displayedImageSize is null, using scale 1.0');
      }

      for (final element in watermarkElements) {
        await _drawWatermarkElement(canvas, size, element, scaleX, scaleY);
      }

      if (drawingStrokes.isNotEmpty) {
        _drawDoodleStrokes(canvas, size, scaleX, scaleY);
      }

      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(
        processedImage.width,
        processedImage.height,
      );
      final byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Error generating watermarked image: $e');
      return null;
    }
  }

  Future<void> _drawWatermarkElement(
    Canvas canvas,
    Size imageSize,
    WatermarkElement element,
    double scaleX,
    double scaleY,
  ) async {
    try {
      final scaledPosition = Offset(
        element.position.dx * scaleX,
        element.position.dy * scaleY,
      );

      switch (element.type) {
        case WatermarkType.timeLocation:
          if (element.dynamicData != null && element.templateId != null) {
            WatermarkPainter.drawTimeLocationWatermark(
              canvas,
              element.templateId!,
              element.dynamicData!,
              scaledPosition,
              element.scale * scaleX,
              element.opacity,
            );
          }
          break;

        case WatermarkType.text:
          if (element.text != null && element.text!.isNotEmpty) {
            await _drawTextWatermark(canvas, element, scaledPosition, scaleX);
          }
          break;

        case WatermarkType.avatar:
          if (element.userImagePath != null && element.imagePath != null) {
            await _drawAvatarWatermark(canvas, element, scaledPosition, scaleX);
          } else {
            await _drawPlaceholder(
              canvas,
              element,
              'Avatar',
              scaledPosition,
              scaleX,
            );
          }
          break;

        case WatermarkType.stamp:
          if (element.imagePath != null && element.imagePath!.isNotEmpty) {
            await _drawAssetImageWatermark(
              canvas,
              element,
              scaledPosition,
              scaleX,
            );
          } else {
            await _drawPlaceholder(
              canvas,
              element,
              'Stamp',
              scaledPosition,
              scaleX,
            );
          }
          break;

        case WatermarkType.customImage:
          if (element.imagePath != null) {
            await _drawImageWatermark(canvas, element, scaledPosition, scaleX);
          }
          break;
      }
    } catch (e) {
      print('Error drawing watermark element: $e');
    }
  }

  Future<void> _drawImageWatermark(
    Canvas canvas,
    WatermarkElement element,
    Offset position,
    double scaleX,
  ) async {
    try {
      if (element.imagePath == null) return;

      File imageFile;
      if (element.imagePath!.startsWith('assets/')) {
        return;
      } else {
        imageFile = File(element.imagePath!);
        if (!await imageFile.exists()) return;
      }

      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final paint = Paint()..color = Colors.white.withOpacity(element.opacity);

      canvas.save();
      canvas.translate(position.dx, position.dy);

      final scaledSize =
          WatermarkBaseSizes.customImage * scaleX * element.scale;
      final imageScale = scaledSize / image.width;

      canvas.scale(imageScale);
      canvas.drawImage(image, Offset.zero, paint);
      canvas.restore();
    } catch (e) {
      print('Error drawing image watermark: $e');
    }
  }

  Future<void> _drawTextWatermark(
    Canvas canvas,
    WatermarkElement element,
    Offset position,
    double scaleX,
  ) async {
    if (element.text == null || element.text!.isEmpty) return;

    final textSpan = TextSpan(
      text: element.text,
      style: TextStyle(
        fontSize: (element.textSize ?? 32) * scaleX * element.scale,
        color: (element.textColor ?? Colors.white).withOpacity(element.opacity),
        fontWeight: (element.isBold ?? false)
            ? FontWeight.bold
            : FontWeight.normal,
        fontStyle: (element.isItalic ?? false)
            ? FontStyle.italic
            : FontStyle.normal,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  Future<void> _drawPlaceholder(
    Canvas canvas,
    WatermarkElement element,
    String label,
    Offset position,
    double scaleX,
  ) async {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(element.opacity * 0.3)
      ..style = PaintingStyle.fill;

    final width = 80.0 * scaleX * element.scale;
    final height = 80.0 * scaleX * element.scale;

    canvas.drawRect(
      Rect.fromLTWH(position.dx, position.dy, width, height),
      paint,
    );

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(element.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromLTWH(position.dx, position.dy, width, height),
      borderPaint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 12 * element.scale,
          color: Colors.white.withOpacity(element.opacity),
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: width);
    textPainter.paint(
      canvas,
      Offset(
        position.dx + (width - textPainter.width) / 2,
        position.dy + (height - textPainter.height) / 2,
      ),
    );
  }

  Future<void> _drawAvatarWatermark(
    Canvas canvas,
    WatermarkElement element,
    Offset position,
    double scaleX,
  ) async {
    try {
      final size = WatermarkBaseSizes.avatar * scaleX * element.scale;

      final avatarFile = File(element.userImagePath!);
      if (!await avatarFile.exists()) {
        await _drawPlaceholder(canvas, element, 'Avatar', position, scaleX);
        return;
      }

      final avatarBytes = await avatarFile.readAsBytes();
      final avatarCodec = await ui.instantiateImageCodec(
        avatarBytes,
        targetWidth: size.toInt(),
        targetHeight: size.toInt(),
      );
      final avatarFrame = await avatarCodec.getNextFrame();
      final avatarImage = avatarFrame.image;

      final frameData = await _loadAssetImage(element.imagePath!);
      if (frameData == null) {
        final paint = Paint()
          ..color = Colors.white.withOpacity(element.opacity);
        canvas.drawImage(avatarImage, Offset(position.dx, position.dy), paint);
        return;
      }

      final frameCodec = await ui.instantiateImageCodec(
        frameData,
        targetWidth: size.toInt(),
        targetHeight: size.toInt(),
      );
      final frameFrame = await frameCodec.getNextFrame();
      final frameImage = frameFrame.image;

      final paint = Paint()..color = Colors.white.withOpacity(element.opacity);

      canvas.drawImage(avatarImage, Offset(position.dx, position.dy), paint);

      canvas.drawImage(frameImage, Offset(position.dx, position.dy), paint);
    } catch (e) {
      print('Error drawing avatar watermark: $e');
      await _drawPlaceholder(canvas, element, 'Avatar', position, scaleX);
    }
  }

  Future<void> _drawAssetImageWatermark(
    Canvas canvas,
    WatermarkElement element,
    Offset position,
    double scaleX,
  ) async {
    try {
      final imageData = await _loadAssetImage(element.imagePath!);
      if (imageData == null) {
        await _drawPlaceholder(canvas, element, 'Stamp', position, scaleX);
        return;
      }

      final size = WatermarkBaseSizes.stamp * scaleX * element.scale;
      final codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: size.toInt(),
        targetHeight: size.toInt(),
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final paint = Paint()..color = Colors.white.withOpacity(element.opacity);
      canvas.drawImage(image, Offset(position.dx, position.dy), paint);

      if (element.stampText != null && element.stampText!.isNotEmpty) {
        final isVertical = element.stampTextVertical ?? false;
        final textSize = (element.stampTextSize ?? 20) * scaleX * element.scale;
        final textColor = (element.stampTextColor ?? const Color(0xFF8B0000))
            .withOpacity(element.opacity);

        if (isVertical) {
          double yOffset =
              position.dy +
              (size - (element.stampText!.length * textSize * 1.2)) / 2;
          for (var i = 0; i < element.stampText!.length; i++) {
            final charSpan = TextSpan(
              text: element.stampText![i],
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.2,
              ),
            );

            final charPainter = TextPainter(
              text: charSpan,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
            );

            charPainter.layout();
            charPainter.paint(
              canvas,
              Offset(position.dx + (size - charPainter.width) / 2, yOffset),
            );
            yOffset += textSize * 1.2;
          }
        } else {
          final textSpan = TextSpan(
            text: element.stampText,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          );

          final textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );

          textPainter.layout(maxWidth: size * 0.8);

          final textOffset = Offset(
            position.dx + (size - textPainter.width) / 2,
            position.dy + (size - textPainter.height) / 2,
          );

          textPainter.paint(canvas, textOffset);
        }
      }
    } catch (e) {
      print('Error drawing asset image watermark: $e');
      await _drawPlaceholder(canvas, element, 'Stamp', position, scaleX);
    }
  }

  Future<Uint8List?> _loadAssetImage(String assetPath) async {
    try {
      final data = await DefaultAssetBundle.of(Get.context!).load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      print('Error loading asset image: $e');
      return null;
    }
  }

  void _drawDoodleStrokes(
    Canvas canvas,
    Size imageSize,
    double scaleX,
    double scaleY,
  ) {
    for (final stroke in drawingStrokes) {
      if (stroke.points.length < 2) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth =
            stroke.width *
            scaleX // Scale stroke width
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
      final firstPoint = Offset(
        stroke.points.first.offset.dx * scaleX,
        stroke.points.first.offset.dy * scaleY,
      );
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (int i = 1; i < stroke.points.length; i++) {
        final point = Offset(
          stroke.points[i].offset.dx * scaleX,
          stroke.points[i].offset.dy * scaleY,
        );

        if (stroke.brushType == BrushType.dashed && i > 0) {
          final prevPoint = Offset(
            stroke.points[i - 1].offset.dx * scaleX,
            stroke.points[i - 1].offset.dy * scaleY,
          );
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
}
