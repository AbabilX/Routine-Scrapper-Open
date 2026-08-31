import 'package:flutter/material.dart';

import 'cute_face.dart';
import 'cute_face_kind.dart';

/// Cute face + title + subtitle — matches Student homepage header.
class CuteHeader extends StatelessWidget {
  const CuteHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.faceKind = CuteFaceKind.bunny,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final CuteFaceKind faceKind;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        CuteFace(size: 52, kind: faceKind),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: text.labelSmall),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
