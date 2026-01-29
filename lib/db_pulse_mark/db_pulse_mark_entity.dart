import 'dart:convert';

class AppSetting {
  String key;
  String value;
  String updatedAt;

  AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'updated_at': updatedAt,
    };
  }

  factory AppSetting.fromMap(Map<String, dynamic> map) {
    return AppSetting(
      key: map['key'],
      value: map['value'],
      updatedAt: map['updated_at'],
    );
  }
}

class WatermarkHistory {
  int? id;
  String imagePath;
  String watermarkText;
  String watermarkPosition;
  double watermarkOpacity;
  double watermarkSize;
  String watermarkColor;
  String textContent;
  double textSize;
  String textColor;
  int isBold;
  int isItalic;
  String createdAt;
  String? updatedAt;

  WatermarkHistory({
    this.id,
    required this.imagePath,
    this.watermarkText = '',
    this.watermarkPosition = 'bottom-right',
    this.watermarkOpacity = 0.5,
    this.watermarkSize = 24.0,
    this.watermarkColor = '#FFFFFFFF',
    this.textContent = '',
    this.textSize = 32.0,
    this.textColor = '#FFFFFFFF',
    this.isBold = 0,
    this.isItalic = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'watermark_text': watermarkText,
      'watermark_position': watermarkPosition,
      'watermark_opacity': watermarkOpacity,
      'watermark_size': watermarkSize,
      'watermark_color': watermarkColor,
      'text_content': textContent,
      'text_size': textSize,
      'text_color': textColor,
      'is_bold': isBold,
      'is_italic': isItalic,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory WatermarkHistory.fromMap(Map<String, dynamic> map) {
    return WatermarkHistory(
      id: map['id'],
      imagePath: map['image_path'],
      watermarkText: map['watermark_text'] ?? '',
      watermarkPosition: map['watermark_position'] ?? 'bottom-right',
      watermarkOpacity: map['watermark_opacity'] ?? 0.5,
      watermarkSize: map['watermark_size'] ?? 24.0,
      watermarkColor: map['watermark_color'] ?? '#FFFFFFFF',
      textContent: map['text_content'] ?? '',
      textSize: map['text_size'] ?? 32.0,
      textColor: map['text_color'] ?? '#FFFFFFFF',
      isBold: map['is_bold'] ?? 0,
      isItalic: map['is_italic'] ?? 0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}

class GridCutHistory {
  int? id;
  String timestamp;
  String gridMode;
  int rows;
  int cols;
  String filePaths;
  String createdAt;

  GridCutHistory({
    this.id,
    required this.timestamp,
    required this.gridMode,
    required this.rows,
    required this.cols,
    required this.filePaths,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'grid_mode': gridMode,
      'rows': rows,
      'cols': cols,
      'file_paths': filePaths,
      'created_at': createdAt,
    };
  }

  factory GridCutHistory.fromMap(Map<String, dynamic> map) {
    return GridCutHistory(
      id: map['id'],
      timestamp: map['timestamp'],
      gridMode: map['grid_mode'],
      rows: map['rows'],
      cols: map['cols'],
      filePaths: map['file_paths'],
      createdAt: map['created_at'],
    );
  }

  List<String> getFilePathsList() {
    return (jsonDecode(filePaths) as List).cast<String>();
  }
}
