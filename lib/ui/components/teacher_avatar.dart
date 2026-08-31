import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular photo from [imageUrl], or a person icon if missing / load fails.
class TeacherAvatar extends StatelessWidget {
  const TeacherAvatar({
    super.key,
    this.imageUrl = '',
    this.size = 56,
    this.backgroundColor = lavender,
  });

  final String imageUrl;
  final double size;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final fallback = _Fallback(size: size, backgroundColor: backgroundColor);
    if (imageUrl.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.size, required this.backgroundColor});

  final double size;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: ink, size: size * 0.5),
    );
  }
}
