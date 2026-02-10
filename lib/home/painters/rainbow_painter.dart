import 'dart:math';
import 'package:flutter/material.dart';
import 'common.dart';

class RainbowPainter extends CustomPainter {
  static const xLength = 20.0;
  static const yLength = 5.0;

  final double relativeOffset;
  final double angleInRadians;
  final int frame;
  final int tailCount;
  final Paint paintBrush;
  final double sizeMultiplier;

  RainbowPainter({
    required this.relativeOffset,
    required this.frame,
    this.tailCount = 12,
    this.angleInRadians = 0,
    Paint? paintBrush,
    this.sizeMultiplier = 5,
  })  : paintBrush = paintBrush ??
      Paint()
        ..strokeWidth = 10
        ..isAntiAlias = true
        ..color = Color.fromRGBO(
          Random().nextInt(255),
          Random().nextInt(255),
          Random().nextInt(255),
          1,
        ),
        assert(tailCount % 2 == 0,
        'Should be an even number, or tail swing animation goes from start');

  @override
  void paint(Canvas canvas, Size size) {
    canvas.rotate(angleInRadians);
    var generalOffset = Offset(
      size.width * relativeOffset + kFadeInOffset,
      size.height / 2,
    );

    for (var i = tailCount; i > 0; i--) {
      if (i % 2 == 0) {
        generalOffset =
            generalOffset.translate(0, frame < 3 ? -yLength : yLength);
      } else {
        generalOffset =
            generalOffset.translate(0, frame < 3 ? yLength : -yLength);
      }

      final colors = [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.purple,
      ];

      for (int j = 0; j < colors.length; j++) {
        canvas.drawLine(
          generalOffset.translate(-i * xLength, (j * 2 - 5) * sizeMultiplier),
          generalOffset.translate(xLength - i * xLength, (j * 2 - 5) * sizeMultiplier),
          paintBrush..color = colors[j].withOpacity(1 - i / tailCount),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
