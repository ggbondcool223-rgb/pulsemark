import 'dart:ui';
import 'package:uuid/uuid.dart';

class WatermarkBaseSizes {
  static const double avatar = 80.0;
  static const double stamp = 70.0;
  static const double customImage = 100.0;
  static const Map<String, Size> timeLocation = {
    'time_location_1': Size(100.0, 60.0),
    'time_location_2': Size(110.0, 80.0),
    'time_location_3': Size(100.0, 50.0),
    'time_location_4': Size(120.0, 90.0),
  };

  static const Size timeLocationDefault = Size(120.0, 80.0);

  static Size getTimeLocationSize(String? templateId) {
    return timeLocation[templateId] ?? timeLocationDefault;
  }
}

enum WatermarkType {
  avatar,
  timeLocation,
  stamp,
  customImage,
  text,
}

class WatermarkElement {
  final String id;
  final WatermarkType type;
  Offset position;
  double opacity;
  double scale;

  final String? templateId;

  final String? imagePath;

  final String? userImagePath;

  final Map<String, dynamic>? dynamicData;

  final String? text;
  final Color? textColor;
  final double? textSize;
  final bool? isBold;
  final bool? isItalic;

  final String? stampText;
  final Color? stampTextColor;
  final double? stampTextSize;
  final bool? stampTextVertical;

  WatermarkElement({
    String? id,
    required this.type,
    Offset? position,
    this.opacity = 1.0,
    this.scale = 1.0,
    this.templateId,
    this.imagePath,
    this.userImagePath,
    this.dynamicData,
    this.text,
    this.textColor,
    this.textSize,
    this.isBold,
    this.isItalic,
    this.stampText,
    this.stampTextColor,
    this.stampTextSize,
    this.stampTextVertical,
  }) : id = id ?? const Uuid().v4(),
       position = position ?? Offset.zero;

  factory WatermarkElement.avatar({
    required String templateId,
    required String templatePath,
    required String userAvatarPath,
    Offset? position,
  }) {
    return WatermarkElement(
      type: WatermarkType.avatar,
      templateId: templateId,
      imagePath: templatePath,
      userImagePath: userAvatarPath,
      position: position,
      scale: 1.0,
    );
  }

  factory WatermarkElement.timeLocation({
    required String templateId,
    required String templatePath,
    required Map<String, dynamic> dynamicData,
    Offset? position,
  }) {
    return WatermarkElement(
      type: WatermarkType.timeLocation,
      templateId: templateId,
      imagePath: templatePath,
      dynamicData: dynamicData,
      position: position,
      scale: 1.0,
    );
  }

  factory WatermarkElement.stamp({
    required String templateId,
    required String templatePath,
    Offset? position,
    String? stampText,
    Color? stampTextColor,
    double? stampTextSize,
    bool? stampTextVertical,
  }) {
    return WatermarkElement(
      type: WatermarkType.stamp,
      templateId: templateId,
      imagePath: templatePath,
      position: position,
      scale: 1.0,
      stampText: stampText,
      stampTextColor: stampTextColor ?? const Color(0xFF8B0000),
      stampTextSize: stampTextSize ?? 20.0,
      stampTextVertical: stampTextVertical ?? false,
    );
  }

  factory WatermarkElement.customImage({
    required String imagePath,
    Offset? position,
  }) {
    return WatermarkElement(
      type: WatermarkType.customImage,
      imagePath: imagePath,
      position: position,
      scale: 1.0,
    );
  }

  factory WatermarkElement.text({
    required String text,
    Color? textColor,
    double? textSize,
    bool? isBold,
    bool? isItalic,
    Offset? position,
  }) {
    return WatermarkElement(
      type: WatermarkType.text,
      text: text,
      textColor: textColor,
      textSize: textSize,
      isBold: isBold,
      isItalic: isItalic,
      position: position,
      scale: 1.0,
    );
  }

  WatermarkElement copyWith({
    Offset? position,
    double? opacity,
    double? scale,
    String? userImagePath,
    Map<String, dynamic>? dynamicData,
    String? text,
    Color? textColor,
    double? textSize,
    bool? isBold,
    bool? isItalic,
    String? stampText,
    Color? stampTextColor,
    double? stampTextSize,
    bool? stampTextVertical,
  }) {
    return WatermarkElement(
      id: id,
      type: type,
      position: position ?? this.position,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      templateId: templateId,
      imagePath: imagePath,
      userImagePath: userImagePath ?? this.userImagePath,
      dynamicData: dynamicData ?? this.dynamicData,
      text: text ?? this.text,
      textColor: textColor ?? this.textColor,
      textSize: textSize ?? this.textSize,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      stampText: stampText ?? this.stampText,
      stampTextColor: stampTextColor ?? this.stampTextColor,
      stampTextSize: stampTextSize ?? this.stampTextSize,
      stampTextVertical: stampTextVertical ?? this.stampTextVertical,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'position': {'dx': position.dx, 'dy': position.dy},
      'opacity': opacity,
      'scale': scale,
      'templateId': templateId,
      'imagePath': imagePath,
      'userImagePath': userImagePath,
      'dynamicData': dynamicData,
      'text': text,
      'textColor': textColor?.value,
      'textSize': textSize,
      'isBold': isBold,
      'isItalic': isItalic,
      'stampText': stampText,
      'stampTextColor': stampTextColor?.value,
      'stampTextSize': stampTextSize,
      'stampTextVertical': stampTextVertical,
    };
  }

  factory WatermarkElement.fromJson(Map<String, dynamic> json) {
    return WatermarkElement(
      id: json['id'],
      type: WatermarkType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      position: Offset(
        json['position']['dx'] ?? 0.0,
        json['position']['dy'] ?? 0.0,
      ),
      opacity: json['opacity'] ?? 1.0,
      scale: json['scale'] ?? 1.0,
      templateId: json['templateId'],
      imagePath: json['imagePath'],
      userImagePath: json['userImagePath'],
      dynamicData: json['dynamicData'],
      text: json['text'],
      textColor: json['textColor'] != null ? Color(json['textColor']) : null,
      textSize: json['textSize'],
      isBold: json['isBold'],
      isItalic: json['isItalic'],
      stampText: json['stampText'],
      stampTextColor: json['stampTextColor'] != null ? Color(json['stampTextColor']) : null,
      stampTextSize: json['stampTextSize'],
      stampTextVertical: json['stampTextVertical'],
    );
  }
}

class WatermarkTemplate {
  final String id;
  final String name;
  final WatermarkType type;
  final String thumbnailPath;
  final String? fullImagePath;

  const WatermarkTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.thumbnailPath,
    this.fullImagePath,
  });
}

class WatermarkTemplates {
  static const List<WatermarkTemplate> avatarTemplates = [
    WatermarkTemplate(
      id: 'avatar_1',
      name: 'Circle Frame',
      type: WatermarkType.avatar,
      thumbnailPath: 'assets/watermarks/avatar/avatar_1.webp',
    ),
    WatermarkTemplate(
      id: 'avatar_2',
      name: 'Square Frame',
      type: WatermarkType.avatar,
      thumbnailPath: 'assets/watermarks/avatar/avatar_2.webp',
    ),
    WatermarkTemplate(
      id: 'avatar_3',
      name: 'Decorated Circle',
      type: WatermarkType.avatar,
      thumbnailPath: 'assets/watermarks/avatar/avatar_3.webp',
    ),
    WatermarkTemplate(
      id: 'avatar_4',
      name: 'Polaroid Style',
      type: WatermarkType.avatar,
      thumbnailPath: 'assets/watermarks/avatar/avatar_4.webp',
    ),
    WatermarkTemplate(
      id: 'avatar_5',
      name: 'Frame 5',
      type: WatermarkType.avatar,
      thumbnailPath: 'assets/watermarks/avatar/avatar_5.webp',
    ),
    WatermarkTemplate(
      id: 'avatar_6',
      name: 'Frame 6',
      type: WatermarkType.avatar,
      thumbnailPath: 'assets/watermarks/avatar/avatar_6.png',
    ),
    WatermarkTemplate(
      id: 'avatar_7',
      name: 'Frame 7',
      type: WatermarkType.avatar,
      thumbnailPath: 'assets/watermarks/avatar/avatar_7.webp',
    ),
    WatermarkTemplate(
      id: 'avatar_8',
      name: 'Frame 8',
      type: WatermarkType.avatar,
      thumbnailPath: 'assets/watermarks/avatar/avatar_8.webp',
    ),
  ];

  static const List<WatermarkTemplate> timeLocationTemplates = [
    WatermarkTemplate(
      id: 'time_location_1',
      name: 'Minimal',
      type: WatermarkType.timeLocation,
      thumbnailPath: '',
    ),
    WatermarkTemplate(
      id: 'time_location_2',
      name: 'Card',
      type: WatermarkType.timeLocation,
      thumbnailPath: '',
    ),
    WatermarkTemplate(
      id: 'time_location_3',
      name: 'Modern',
      type: WatermarkType.timeLocation,
      thumbnailPath: '',
    ),
    WatermarkTemplate(
      id: 'time_location_4',
      name: 'Classic',
      type: WatermarkType.timeLocation,
      thumbnailPath: '',
    ),
  ];

  static const List<WatermarkTemplate> stampTemplates = [
    WatermarkTemplate(
      id: 'stamp_1',
      name: 'Round Stamp',
      type: WatermarkType.stamp,
      thumbnailPath: 'assets/watermarks/stamp/stamp_1.webp',
    ),
    WatermarkTemplate(
      id: 'stamp_2',
      name: 'Square Stamp',
      type: WatermarkType.stamp,
      thumbnailPath: 'assets/watermarks/stamp/stamp_2.webp',
    ),
    WatermarkTemplate(
      id: 'stamp_3',
      name: 'Chinese Seal',
      type: WatermarkType.stamp,
      thumbnailPath: 'assets/watermarks/stamp/stamp_3.webp',
    ),
    WatermarkTemplate(
      id: 'stamp_4',
      name: 'Postage Stamp',
      type: WatermarkType.stamp,
      thumbnailPath: 'assets/watermarks/stamp/stamp_4.webp',
    ),
    WatermarkTemplate(
      id: 'stamp_5',
      name: 'Stamp 5',
      type: WatermarkType.stamp,
      thumbnailPath: 'assets/watermarks/stamp/stamp_5.webp',
    ),
  ];

  static List<WatermarkTemplate> getTemplatesByType(WatermarkType type) {
    switch (type) {
      case WatermarkType.avatar:
        return avatarTemplates;
      case WatermarkType.timeLocation:
        return timeLocationTemplates;
      case WatermarkType.stamp:
        return stampTemplates;
      default:
        return [];
    }
  }
}
