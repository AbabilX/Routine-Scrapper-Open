import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

class QuickChips extends StatelessWidget {
  const QuickChips({super.key, required this.chips, required this.onSelect});

  final List<String> chips;
  final ValueChanged<String> onSelect;

  static List<Color> get _tints => [
    peach,
    lavender,
    sky,
    peach.withValues(alpha: 0.85),
  ];

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final tint = _tints[(_javaHash(chip) & 0x7fffffff) % _tints.length];
          return Material(
            color: tint,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                onSelect(chip);
              },
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(chip, style: text.labelLarge),
              ),
            ),
          );
        },
      ),
    );
  }

  static int _javaHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (31 * hash + unit).toSigned(32);
    }
    return hash;
  }
}
