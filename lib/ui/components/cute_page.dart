import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'decor_blobs.dart';

/// Shared Student-style page shell: pastel bg, blobs, SafeArea scroll.
class CutePage extends StatelessWidget {
  const CutePage({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(22, 12, 22, 40),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bg,
      child: Stack(
        children: [
          const DecorBlobs(),
          SafeArea(
            child: ListView(padding: padding, children: children),
          ),
        ],
      ),
    );
  }
}
