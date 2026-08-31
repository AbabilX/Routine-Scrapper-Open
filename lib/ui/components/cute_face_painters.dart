import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'cute_face_kind.dart';

class CuteFacePainter extends CustomPainter {
  const CuteFacePainter({required this.kind, required this.blink});

  final CuteFaceKind kind;
  final double blink;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    switch (kind) {
      case CuteFaceKind.bunny:
        _bunny(canvas, w, h);
      case CuteFaceKind.cat:
        _cat(canvas, w, h);
      case CuteFaceKind.chick:
        _chick(canvas, w, h);
      case CuteFaceKind.deer:
        _deer(canvas, w, h);
      case CuteFaceKind.fox:
        _fox(canvas, w, h);
      case CuteFaceKind.wolf:
        _wolf(canvas, w, h);
      case CuteFaceKind.raccoon:
        _raccoon(canvas, w, h);
      case CuteFaceKind.bear:
        _bear(canvas, w, h);
      case CuteFaceKind.baldGrin:
        _bald(canvas, w, h, variant: _BaldVariant.grin);
      case CuteFaceKind.baldWink:
        _bald(canvas, w, h, variant: _BaldVariant.wink);
      case CuteFaceKind.baldGlasses:
        _bald(canvas, w, h, variant: _BaldVariant.glasses);
      case CuteFaceKind.baldBow:
        _bald(canvas, w, h, variant: _BaldVariant.bow);
    }
  }

  void _cat(Canvas canvas, double w, double h) {
    final ear = Paint()..color = ink;
    _ear(
      canvas,
      Offset(w * 0.22, h * 0.08),
      Offset(w * 0.12, h * 0.38),
      Offset(w * 0.36, h * 0.28),
      ear,
    );
    _ear(
      canvas,
      Offset(w * 0.78, h * 0.08),
      Offset(w * 0.88, h * 0.38),
      Offset(w * 0.64, h * 0.28),
      ear,
    );
    _eyes(canvas, w, h, y: 0.44, radius: 0.048);
    _whisker(canvas, w, h, left: true);
    _whisker(canvas, w, h, left: false);
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.58),
      w * 0.035,
      Paint()..color = rose,
    );
    _smile(canvas, w, h, top: 0.58, width: 0.18);
  }

  void _bunny(Canvas canvas, double w, double h) {
    final ear = Paint()..color = surface;
    final inner = Paint()..color = rose.withValues(alpha: 0.7);
    _ear(
      canvas,
      Offset(w * 0.32, h * 0.02),
      Offset(w * 0.22, h * 0.34),
      Offset(w * 0.42, h * 0.3),
      ear,
    );
    _ear(
      canvas,
      Offset(w * 0.68, h * 0.02),
      Offset(w * 0.58, h * 0.3),
      Offset(w * 0.78, h * 0.34),
      ear,
    );
    _ear(
      canvas,
      Offset(w * 0.32, h * 0.06),
      Offset(w * 0.26, h * 0.28),
      Offset(w * 0.38, h * 0.26),
      inner,
    );
    _ear(
      canvas,
      Offset(w * 0.68, h * 0.06),
      Offset(w * 0.62, h * 0.26),
      Offset(w * 0.74, h * 0.28),
      inner,
    );
    _eyes(canvas, w, h, y: 0.46);
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.6),
      w * 0.03,
      Paint()..color = rose,
    );
    _smile(canvas, w, h, top: 0.58);
  }

  void _chick(Canvas canvas, double w, double h) {
    _eyes(canvas, w, h, y: 0.42, radius: 0.05);
    final beak = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.42, h * 0.58)
      ..lineTo(w * 0.58, h * 0.58)
      ..close();
    canvas.drawPath(beak, Paint()..color = peach);
    canvas.drawCircle(
      Offset(w * 0.22, h * 0.62),
      w * 0.07,
      Paint()..color = peach.withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.62),
      w * 0.07,
      Paint()..color = peach.withValues(alpha: 0.7),
    );
  }

  void _deer(Canvas canvas, double w, double h) {
    final antler = Paint()
      ..color = ink
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(w * 0.32, h * 0.28),
      Offset(w * 0.22, h * 0.08),
      antler,
    );
    canvas.drawLine(
      Offset(w * 0.26, h * 0.16),
      Offset(w * 0.16, h * 0.12),
      antler,
    );
    canvas.drawLine(
      Offset(w * 0.68, h * 0.28),
      Offset(w * 0.78, h * 0.08),
      antler,
    );
    canvas.drawLine(
      Offset(w * 0.74, h * 0.16),
      Offset(w * 0.84, h * 0.12),
      antler,
    );
    _eyes(canvas, w, h, y: 0.46, radius: 0.045);
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.6),
      w * 0.028,
      Paint()..color = rose,
    );
    _smile(canvas, w, h, top: 0.58, width: 0.2);
  }

  void _fox(Canvas canvas, double w, double h) {
    final ear = Paint()..color = ink;
    _ear(
      canvas,
      Offset(w * 0.2, h * 0.04),
      Offset(w * 0.1, h * 0.36),
      Offset(w * 0.36, h * 0.3),
      ear,
    );
    _ear(
      canvas,
      Offset(w * 0.8, h * 0.04),
      Offset(w * 0.9, h * 0.36),
      Offset(w * 0.64, h * 0.3),
      ear,
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.62),
      w * 0.16,
      Paint()..color = surface,
    );
    _eyes(canvas, w, h, y: 0.44, radius: 0.05);
    _triangleNose(canvas, w, h);
    _smile(canvas, w, h, top: 0.58, width: 0.2);
  }

  void _wolf(Canvas canvas, double w, double h) {
    final ear = Paint()..color = ink;
    _ear(
      canvas,
      Offset(w * 0.24, h * 0.02),
      Offset(w * 0.12, h * 0.34),
      Offset(w * 0.38, h * 0.3),
      ear,
    );
    _ear(
      canvas,
      Offset(w * 0.76, h * 0.02),
      Offset(w * 0.88, h * 0.34),
      Offset(w * 0.62, h * 0.3),
      ear,
    );
    _eyes(canvas, w, h, y: 0.42, radius: 0.042);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.62),
        width: w * 0.28,
        height: h * 0.16,
      ),
      Paint()..color = surface,
    );
    _triangleNose(canvas, w, h, y: 0.56);
    _smile(canvas, w, h, top: 0.6, width: 0.16);
  }

  void _raccoon(Canvas canvas, double w, double h) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, h * 0.36, w * 0.68, h * 0.2),
        Radius.circular(w * 0.1),
      ),
      Paint()..color = ink.withValues(alpha: 0.22),
    );
    _eyes(canvas, w, h, y: 0.44, radius: 0.05);
    _triangleNose(canvas, w, h);
    _smile(canvas, w, h, top: 0.58, width: 0.18);
  }

  void _bear(Canvas canvas, double w, double h) {
    canvas.drawCircle(
      Offset(w * 0.22, h * 0.22),
      w * 0.14,
      Paint()..color = ink.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.22),
      w * 0.14,
      Paint()..color = ink.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.62),
      w * 0.18,
      Paint()..color = surface,
    );
    _eyes(canvas, w, h, y: 0.42);
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.58),
      w * 0.04,
      Paint()..color = ink,
    );
    _smile(canvas, w, h, top: 0.6, width: 0.22);
  }

  void _bald(
    Canvas canvas,
    double w,
    double h, {
    required _BaldVariant variant,
  }) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.38, h * 0.16),
        width: w * 0.22,
        height: h * 0.1,
      ),
      Paint()..color = surface.withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      Offset(w * 0.18, h * 0.52),
      w * 0.07,
      Paint()..color = ink.withValues(alpha: 0.08),
    );
    canvas.drawCircle(
      Offset(w * 0.82, h * 0.52),
      w * 0.07,
      Paint()..color = ink.withValues(alpha: 0.08),
    );

    switch (variant) {
      case _BaldVariant.grin:
        _eyes(canvas, w, h, y: 0.42);
        _smile(canvas, w, h, top: 0.52, width: 0.34);
      case _BaldVariant.wink:
        _eyes(canvas, w, h, y: 0.42, leftOpen: 0.18, rightOpen: 1);
        _smile(canvas, w, h, top: 0.54, width: 0.28);
      case _BaldVariant.glasses:
        _eyes(canvas, w, h, y: 0.44, radius: 0.042);
        _glasses(canvas, w, h);
        _smile(canvas, w, h, top: 0.58, width: 0.2);
      case _BaldVariant.bow:
        _eyes(canvas, w, h, y: 0.4, radius: 0.05);
        _brows(canvas, w, h);
        _smile(canvas, w, h, top: 0.52, width: 0.22);
        _bowTie(canvas, w, h);
    }
  }

  void _glasses(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035;
    canvas.drawCircle(Offset(w * 0.36, h * 0.44), w * 0.12, paint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.44), w * 0.12, paint);
    canvas.drawLine(
      Offset(w * 0.48, h * 0.44),
      Offset(w * 0.52, h * 0.44),
      paint,
    );
  }

  void _brows(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = ink
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.28, h * 0.32),
      Offset(w * 0.42, h * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.58, h * 0.3),
      Offset(w * 0.72, h * 0.32),
      paint,
    );
  }

  void _bowTie(Canvas canvas, double w, double h) {
    final paint = Paint()..color = ink;
    final left = Path()
      ..moveTo(w * 0.5, h * 0.82)
      ..lineTo(w * 0.32, h * 0.74)
      ..lineTo(w * 0.32, h * 0.9)
      ..close();
    final right = Path()
      ..moveTo(w * 0.5, h * 0.82)
      ..lineTo(w * 0.68, h * 0.74)
      ..lineTo(w * 0.68, h * 0.9)
      ..close();
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.82), w * 0.035, paint);
  }

  void _triangleNose(Canvas canvas, double w, double h, {double y = 0.54}) {
    final nose = Path()
      ..moveTo(w * 0.5, h * y)
      ..lineTo(w * 0.45, h * (y + 0.06))
      ..lineTo(w * 0.55, h * (y + 0.06))
      ..close();
    canvas.drawPath(nose, Paint()..color = ink);
  }

  void _ear(Canvas canvas, Offset tip, Offset left, Offset right, Paint paint) {
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _eyes(
    Canvas canvas,
    double w,
    double h, {
    required double y,
    double radius = 0.055,
    double leftOpen = 1,
    double rightOpen = 1,
  }) {
    final r = w * radius;
    _eye(
      canvas,
      Offset(w * 0.36, h * y),
      r,
      (leftOpen * (1 - blink * 0.92)).clamp(0.12, 1),
    );
    _eye(
      canvas,
      Offset(w * 0.64, h * y),
      r,
      (rightOpen * (1 - blink * 0.92)).clamp(0.12, 1),
    );
  }

  void _eye(Canvas canvas, Offset center, double r, double open) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1, open);
    canvas.drawCircle(Offset.zero, r, Paint()..color = ink);
    canvas.restore();
  }

  void _smile(
    Canvas canvas,
    double w,
    double h, {
    required double top,
    double width = 0.24,
  }) {
    final smile = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(w * (0.5 - width / 2), h * top, w * width, h * 0.18),
      20 * math.pi / 180,
      140 * math.pi / 180,
      false,
      smile,
    );
  }

  void _whisker(Canvas canvas, double w, double h, {required bool left}) {
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.45)
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round;
    final x = left ? w * 0.18 : w * 0.82;
    final dir = left ? -1.0 : 1.0;
    canvas.drawLine(
      Offset(w * 0.5 + dir * w * 0.12, h * 0.58),
      Offset(x, h * 0.52),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.5 + dir * w * 0.12, h * 0.62),
      Offset(x, h * 0.66),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CuteFacePainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.blink != blink;
  }
}

enum _BaldVariant { grin, wink, glasses, bow }
