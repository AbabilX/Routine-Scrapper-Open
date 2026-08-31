import 'package:flutter/material.dart';

import '../../../domain/model/class_status.dart';
import '../../theme/app_colors.dart';

class NextClassBanner extends StatelessWidget {
  const NextClassBanner({super.key, required this.hint});

  final NowNextHint? hint;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: hint == null
          ? const SizedBox.shrink()
          : _BannerBody(
              key: ValueKey(hint!.block.course + hint!.status.name),
              hint: hint!,
            ),
    );
  }
}

class _BannerBody extends StatelessWidget {
  const _BannerBody({super.key, required this.hint});

  final NowNextHint hint;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isNow = hint.status == ClassStatus.now;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isNow ? mint : sky,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isNow ? 'এখন চলছে' : 'পরের ক্লাস',
                    style: text.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(hint.block.course, style: text.titleLarge),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${hint.block.start} – ${hint.block.end}',
                  style: text.labelLarge,
                ),
                Text(hint.block.room, style: text.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
