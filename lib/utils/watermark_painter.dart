import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class WatermarkPainter {
  static void drawTimeLocationWatermark(
    ui.Canvas canvas,
    String templateId,
    Map<String, dynamic> data,
    Offset position,
    double scale,
    double opacity,
  ) {
    switch (templateId) {
      case 'time_location_1':
        _drawMinimalStyle(canvas, data, position, scale, opacity);
        break;
      case 'time_location_2':
        _drawCardStyle(canvas, data, position, scale, opacity);
        break;
      case 'time_location_3':
        _drawModernStyle(canvas, data, position, scale, opacity);
        break;
      case 'time_location_4':
        _drawClassicStyle(canvas, data, position, scale, opacity);
        break;
      default:
        _drawMinimalStyle(canvas, data, position, scale, opacity);
    }
  }

  static void _drawMinimalStyle(
    ui.Canvas canvas,
    Map<String, dynamic> data,
    Offset position,
    double scale,
    double opacity,
  ) {
    final time = data['time'] ?? '';
    final location = data['location'] ?? '';
    final weather = data['weather'] ?? '';

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    double currentY = position.dy;

    textPainter.text = TextSpan(
      text: time,
      style: TextStyle(
        fontSize: 32 * scale,
        fontWeight: FontWeight.bold,
        color: Colors.white.withOpacity(opacity),
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx, currentY));
    currentY += textPainter.height + (4 * scale);

    textPainter.text = TextSpan(
      text: location,
      style: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(opacity * 0.9),
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx, currentY));
    currentY += textPainter.height + (4 * scale);

    textPainter.text = TextSpan(
      text: weather,
      style: TextStyle(
        fontSize: 18 * scale,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(opacity),
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx, currentY));
  }

  static void _drawCardStyle(
    ui.Canvas canvas,
    Map<String, dynamic> data,
    Offset position,
    double scale,
    double opacity,
  ) {
    final time = data['time'] ?? '';
    final location = data['location'] ?? '';
    final weather = data['weather'] ?? '';

    final cardWidth = 220.0 * scale;
    final cardHeight = 100.0 * scale;
    final cornerRadius = 12.0 * scale;

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.dx, position.dy, cardWidth, cardHeight),
      Radius.circular(cornerRadius),
    );

    final cardPaint = Paint()
      ..color = Colors.black.withOpacity(opacity * 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(cardRect, cardPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(cardRect, borderPaint);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final padding = 12.0 * scale;
    double currentY = position.dy + padding;

    textPainter.text = TextSpan(
      text: time,
      style: TextStyle(
        fontSize: 28 * scale,
        fontWeight: FontWeight.bold,
        color: Colors.white.withOpacity(opacity),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx + (cardWidth - textPainter.width) / 2,
        currentY,
      ),
    );
    currentY += textPainter.height + (6 * scale);

    textPainter.text = TextSpan(
      text: location,
      style: TextStyle(
        fontSize: 14 * scale,
        color: Colors.white.withOpacity(opacity * 0.8),
      ),
    );
    textPainter.layout(maxWidth: cardWidth - padding * 2);
    textPainter.paint(
      canvas,
      Offset(
        position.dx + (cardWidth - textPainter.width) / 2,
        currentY,
      ),
    );
    currentY += textPainter.height + (4 * scale);

    textPainter.text = TextSpan(
      text: weather,
      style: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(opacity),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx + (cardWidth - textPainter.width) / 2,
        currentY,
      ),
    );
  }

  static void _drawModernStyle(
    ui.Canvas canvas,
    Map<String, dynamic> data,
    Offset position,
    double scale,
    double opacity,
  ) {
    final time = data['time'] ?? '';
    final location = data['location'] ?? '';
    final weather = data['weather'] ?? '';

    final width = 200.0 * scale;
    final height = 80.0 * scale;

    final rect = Rect.fromLTWH(position.dx, position.dy, width, height);
    final gradient = ui.Gradient.linear(
      Offset(position.dx, position.dy),
      Offset(position.dx, position.dy + height),
      [
        Colors.purple.withOpacity(opacity * 0.7),
        Colors.blue.withOpacity(opacity * 0.5),
      ],
    );

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(8 * scale),
    );

    canvas.drawRRect(rrect, paint);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    final padding = 12.0 * scale;
    double currentY = position.dy + padding;

    textPainter.text = TextSpan(
      children: [
        TextSpan(
          text: '$weather  ',
          style: TextStyle(
            fontSize: 20 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(opacity),
          ),
        ),
        TextSpan(
          text: time,
          style: TextStyle(
            fontSize: 24 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(opacity),
          ),
        ),
      ],
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx + padding, currentY));
    currentY += textPainter.height + (8 * scale);

    textPainter.text = TextSpan(
      text: '📍 $location',
      style: TextStyle(
        fontSize: 14 * scale,
        color: Colors.white.withOpacity(opacity * 0.9),
      ),
    );
    textPainter.layout(maxWidth: width - padding * 2);
    textPainter.paint(canvas, Offset(position.dx + padding, currentY));
  }

  static void _drawClassicStyle(
    ui.Canvas canvas,
    Map<String, dynamic> data,
    Offset position,
    double scale,
    double opacity,
  ) {
    final time = data['time'] ?? '';
    final date = data['date'] ?? '';
    final location = data['location'] ?? '';
    final weather = data['weather'] ?? '';

    final width = 240.0 * scale;
    final height = 110.0 * scale;
    final padding = 14.0 * scale;

    final outerRect = Rect.fromLTWH(position.dx, position.dy, width, height);
    final innerRect = Rect.fromLTWH(
      position.dx + 4 * scale,
      position.dy + 4 * scale,
      width - 8 * scale,
      height - 8 * scale,
    );

    final outerBorderPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(outerRect, outerBorderPaint);

    final innerBorderPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(innerRect, innerBorderPaint);

    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(opacity * 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(innerRect, bgPaint);

    final cornerPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final cornerLength = 12.0 * scale;
    canvas.drawLine(
      Offset(position.dx + padding, position.dy + padding),
      Offset(position.dx + padding + cornerLength, position.dy + padding),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(position.dx + padding, position.dy + padding),
      Offset(position.dx + padding, position.dy + padding + cornerLength),
      cornerPaint,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    double currentY = position.dy + padding + 8 * scale;

    textPainter.text = TextSpan(
      text: time,
      style: TextStyle(
        fontSize: 32 * scale,
        fontWeight: FontWeight.w700,
        color: Colors.white.withOpacity(opacity),
        fontFeatures: const [ui.FontFeature.tabularFigures()],
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx + (width - textPainter.width) / 2,
        currentY,
      ),
    );
    currentY += textPainter.height + (4 * scale);

    textPainter.text = TextSpan(
      text: date,
      style: TextStyle(
        fontSize: 12 * scale,
        color: Colors.white.withOpacity(opacity * 0.7),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx + (width - textPainter.width) / 2,
        currentY,
      ),
    );
    currentY += textPainter.height + (6 * scale);

    final dividerPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(position.dx + padding * 2, currentY),
      Offset(position.dx + width - padding * 2, currentY),
      dividerPaint,
    );
    currentY += 6 * scale;

    textPainter.text = TextSpan(
      text: '$location\n$weather',
      style: TextStyle(
        fontSize: 13 * scale,
        color: Colors.white.withOpacity(opacity * 0.85),
        height: 1.3,
      ),
    );
    textPainter.layout(maxWidth: width - padding * 2);
    textPainter.paint(
      canvas,
      Offset(
        position.dx + (width - textPainter.width) / 2,
        currentY,
      ),
    );
  }
}

