import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class DecorBlobs extends StatelessWidget {
  const DecorBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _BlobPainter(), child: SizedBox.expand());
  }
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * 0.92, 40),
      160,
      Paint()..color = mint.withValues(alpha: 0.42),
    );
    canvas.drawCircle(
      Offset(-10, size.height * 0.42),
      130,
      Paint()..color = lavender.withValues(alpha: 0.32),
    );
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.78),
      110,
      Paint()..color = peach.withValues(alpha: 0.38),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
