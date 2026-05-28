import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 运行时生成精灵图集，无需外部图片资源。
class SpriteSheetFactory {
  SpriteSheetFactory._();

  static const double frameSize = 64;
  static const int shipFrames = 8;
  static const int bugFrames = 6;
  static const int explodeFrames = 5;

  static ui.Image? shipSheet;
  static ui.Image? bugSheet;
  static ui.Image? explodeSheet;

  static Future<void> preload() async {
    shipSheet ??= await _buildShipSheet();
    bugSheet ??= await _buildBugSheet();
    explodeSheet ??= await _buildExplosionSheet();
  }

  static Future<ui.Image> _buildShipSheet() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (var i = 0; i < shipFrames; i++) {
      _drawShipFrame(canvas, Offset(i * frameSize + frameSize / 2, frameSize / 2), i);
    }
    return recorder.endRecording().toImage(
      (frameSize * shipFrames).toInt(),
      frameSize.toInt(),
    );
  }

  static Future<ui.Image> _buildBugSheet() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (var i = 0; i < bugFrames; i++) {
      _drawBugFrame(canvas, Offset(i * frameSize + frameSize / 2, frameSize / 2), i);
    }
    return recorder.endRecording().toImage(
      (frameSize * bugFrames).toInt(),
      frameSize.toInt(),
    );
  }

  static Future<ui.Image> _buildExplosionSheet() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (var i = 0; i < explodeFrames; i++) {
      _drawExplosionFrame(canvas, Offset(i * frameSize + frameSize / 2, frameSize / 2), i);
    }
    return recorder.endRecording().toImage(
      (frameSize * explodeFrames).toInt(),
      frameSize.toInt(),
    );
  }

  static void _drawShipFrame(Canvas canvas, Offset center, int frame) {
    final wingAngle = sin(frame / shipFrames * pi * 2) * 0.18;
    final flameH = 8 + (frame % 2) * 4.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    final body = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF80DEEA), Color(0xFF00ACC1)],
      ).createShader(const Rect.fromLTWH(-20, -24, 40, 48));

    canvas.drawPath(
      Path()
        ..moveTo(0, -24)
        ..lineTo(18, 14)
        ..lineTo(6, 10)
        ..lineTo(0, 22)
        ..lineTo(-6, 10)
        ..lineTo(-18, 14)
        ..close(),
      body,
    );

    canvas.save();
    canvas.rotate(wingAngle);
    canvas.drawRect(const Rect.fromLTWH(-22, 4, 8, 14), Paint()..color = const Color(0xFF4DD0E1));
    canvas.restore();

    canvas.save();
    canvas.rotate(-wingAngle);
    canvas.drawRect(const Rect.fromLTWH(14, 4, 8, 14), Paint()..color = const Color(0xFF4DD0E1));
    canvas.restore();

    canvas.drawPath(
      Path()
        ..moveTo(-5, 18)
        ..lineTo(0, 18 + flameH)
        ..lineTo(5, 18)
        ..close(),
      Paint()..color = Color.lerp(const Color(0xFFFF7043), const Color(0xFFFFD740), frame / shipFrames)!,
    );

    canvas.drawCircle(const Offset(0, -6), 5, Paint()..color = const Color(0xFFB2EBF2));
    canvas.restore();
  }

  static void _drawBugFrame(Canvas canvas, Offset center, int frame) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    const radius = 18.0;
    canvas.drawCircle(Offset.zero, radius, Paint()..color = const Color(0xFFCE93D8));

    for (var leg = 0; leg < 6; leg++) {
      final baseAngle = leg * pi / 3;
      final wiggle = sin(frame / bugFrames * pi * 2 + leg) * 0.35;
      final angle = baseAngle + wiggle;
      final inner = Offset(cos(angle) * radius, sin(angle) * radius);
      final outer = Offset(cos(angle) * radius * 1.55, sin(angle) * radius * 1.55);
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = const Color(0xFFAB47BC)
          ..strokeWidth = 2.5,
      );
    }

    canvas.drawCircle(const Offset(-7, -5), 4, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(7, -5), 4, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-7, -5), 2, Paint()..color = Colors.black87);
    canvas.drawCircle(const Offset(7, -5), 2, Paint()..color = Colors.black87);
    canvas.restore();
  }

  static void _drawExplosionFrame(Canvas canvas, Offset center, int frame) {
    final t = frame / (explodeFrames - 1);
    final radius = 6 + t * 22;
    final alpha = (1 - t * 0.85).clamp(0.0, 1.0);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFFFD740).withValues(alpha: alpha * 0.35)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius * 0.65,
      Paint()
        ..color = const Color(0xFFFF7043).withValues(alpha: alpha * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4 + t * 0.5;
      final rayLen = radius * (0.8 + t * 0.5);
      canvas.drawLine(
        center,
        Offset(center.dx + cos(angle) * rayLen, center.dy + sin(angle) * rayLen),
        Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.8)
          ..strokeWidth = 2,
      );
    }
  }
}
