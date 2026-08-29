import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CuteFace extends StatelessWidget {
  const CuteFace({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: peach,
          shape: BoxShape.circle,
        ),
        child: CustomPaint(painter: _CuteFacePainter()),
      ),
    );
  }
}

class _CuteFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.58),
      w * 0.18,
      Paint()..color = surface,
    );
    final eyeY = h * 0.42;
    final eyeR = w * 0.055;
    final inkPaint = Paint()..color = ink;
    canvas.drawCircle(Offset(w * 0.36, eyeY), eyeR, inkPaint);
    canvas.drawCircle(Offset(w * 0.64, eyeY), eyeR, inkPaint);
    final smile = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(w * 0.38, h * 0.52, w * 0.24, h * 0.18),
      20 * 3.141592653589793 / 180,
      140 * 3.141592653589793 / 180,
      false,
      smile,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
