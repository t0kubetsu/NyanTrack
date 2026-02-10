import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:just_audio/just_audio.dart';

import '../painters/cat_painter.dart';
import '../painters/rainbow_painter.dart';

class NyanCat extends StatefulWidget {
  final List<ui.Image> frames;
  final double angle;
  final int tailCount;
  final int speed;
  final AudioPlayer audioPlayer;

  const NyanCat({
    super.key,
    required this.frames,
    required this.angle,
    required this.tailCount,
    this.speed = 5000,
    required this.audioPlayer,
  }) : assert(speed < 99999);

  @override
  _NyanCatState createState() => _NyanCatState();
}

class _NyanCatState extends State<NyanCat> with TickerProviderStateMixin {
  late final AnimationController _animOffsetController;
  late final AnimationController _animNyanController;
  late final IntTween _nyanTween;
  late final Duration duration;

  @override
  void initState() {
    super.initState();

    _nyanTween = IntTween(begin: 0, end: widget.frames.length - 1);
    duration = Duration(milliseconds: 700);

    widget.audioPlayer.setVolume(0);

    _animNyanController = AnimationController(
      vsync: this,
      duration: duration,
    )..repeat();

    _animOffsetController = AnimationController(
      vsync: this,
      upperBound: 4, // proportional to tail size
      duration: Duration(milliseconds: widget.speed),
    )
      ..forward()
      ..addListener(() {
        setState(() {
          double val = _animOffsetController.value;
          if (val > 0.0 && val <= 0.5) {
            widget.audioPlayer.setVolume(val * 2);
          } else if (val > 0.5 && val <= 1.5) {
            widget.audioPlayer.setVolume(1.5 - val);
          }
        });
      });

    widget.audioPlayer.seek(Duration(seconds: Random().nextInt(55) + 5));
    widget.audioPlayer.play();
  }

  @override
  void dispose() {
    widget.audioPlayer.stop();
    _animNyanController.dispose();
    _animOffsetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFrame = _nyanTween.animate(_animNyanController).value;

    return CustomPaint(
      painter: RainbowPainter(
        relativeOffset: _animOffsetController.value,
        tailCount: widget.tailCount,
        frame: currentFrame,
        angleInRadians: widget.angle,
      ),
      foregroundPainter: CatPainter(
        image: widget.frames[currentFrame],
        angleInRadians: widget.angle,
        relativeOff: _animOffsetController.value,
      ),
      child: Container(),
    );
  }
}
