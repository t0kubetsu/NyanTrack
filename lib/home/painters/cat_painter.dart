import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'common.dart';

class CatPainter extends CustomPainter {
  final ui.Image image;
  final double relativeOff;
  final double angleInRadians;

  CatPainter({
    required this.relativeOff,
    required this.image,
    required this.angleInRadians,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.rotate(angleInRadians);
    canvas.translate(30, 0);
    paintImage(
      canvas: canvas,
      isAntiAlias: true,
      rect: Rect.fromPoints(
        Offset(
          size.width * relativeOff - 100 + kFadeInOffset,
          size.height / 2 - 35,
        ),
        Offset(
          size.width * relativeOff + 100 + kFadeInOffset,
          size.height / 2 + 35,
        ),
      ),
      image: image,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
