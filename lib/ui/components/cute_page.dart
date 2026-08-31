import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'decor_blobs.dart';

/// Shared Student-style page shell: pastel bg, blobs, SafeArea.
///
/// - [children] → full-page scroll (About, etc.)
/// - [header] + [body] → sticky top zone; only [body] scrolls
class CutePage extends StatelessWidget {
  const CutePage({
    super.key,
    this.children,
    this.header,
    this.body,
    this.padding = const EdgeInsets.fromLTRB(22, 12, 22, 40),
  }) : assert(
          (children != null && header == null && body == null) ||
              (children == null && header != null && body != null),
          'Use either children, or header+body',
        );

  final List<Widget>? children;
  final List<Widget>? header;
  final List<Widget>? body;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bg,
      child: Stack(
        children: [
          const DecorBlobs(),
          SafeArea(
            child: header != null
                ? _PinnedScroll(
                    header: header!,
                    body: body!,
                    padding: padding,
                  )
                : ListView(padding: padding, children: children!),
          ),
        ],
      ),
    );
  }
}

class _PinnedScroll extends StatelessWidget {
  const _PinnedScroll({
    required this.header,
    required this.body,
    required this.padding,
  });

  final List<Widget> header;
  final List<Widget> body;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final resolved = padding.resolve(Directionality.of(context));
    return Padding(
      padding: EdgeInsets.fromLTRB(
        resolved.left,
        resolved.top,
        resolved.right,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...header,
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 18, bottom: resolved.bottom),
              children: body,
            ),
          ),
        ],
      ),
    );
  }
}
