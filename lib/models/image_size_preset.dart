class ImageSizePreset {
  final String name;
  final int? width;
  final int? height;
  final bool isOriginal;
  final bool isCustom;

  const ImageSizePreset({
    required this.name,
    this.width,
    this.height,
    this.isOriginal = false,
    this.isCustom = false,
  });

  static const original = ImageSizePreset(
    name: 'Original Size',
    isOriginal: true,
  );

  static const instagramSquare = ImageSizePreset(
    name: 'Instagram Square',
    width: 1080,
    height: 1080,
  );

  static const instagramPortrait = ImageSizePreset(
    name: 'Instagram Portrait',
    width: 1080,
    height: 1350,
  );

  static const weibo = ImageSizePreset(
    name: 'Weibo',
    width: 1200,
    height: 900,
  );

  static const custom = ImageSizePreset(
    name: 'Custom Size',
    isCustom: true,
  );

  static List<ImageSizePreset> get allPresets => [
        original,
        instagramSquare,
        instagramPortrait,
        weibo,
        custom,
      ];

  String getDisplaySize() {
    if (isOriginal) return 'Keep original size';
    if (isCustom) return 'Enter custom size';
    if (width != null && height != null) {
      return '$width × $height';
    }
    return '';
  }

  @override
  String toString() {
    return 'ImageSizePreset(name: $name, width: $width, height: $height)';
  }
}

