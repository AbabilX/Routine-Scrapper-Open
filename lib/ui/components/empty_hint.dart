import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'cute_face.dart';
import 'cute_face_kind.dart';

class EmptyHint extends StatelessWidget {
  const EmptyHint({
    super.key,
    required this.title,
    required this.body,
    this.tint = lavender,
    this.faceSize = 44,
  });

  final String title;
  final String body;
  final Color tint;
  final double faceSize;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              CuteFace(
                size: faceSize,
                kind: CuteFaceKind
                    .values[title.hashCode.abs() % CuteFaceKind.values.length],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleLarge),
                    const SizedBox(height: 6),
                    Text(body, style: text.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
