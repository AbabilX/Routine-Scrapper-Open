import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Vertical suggestion list — cute Student-style pastel rows.
class SuggestionList extends StatelessWidget {
  const SuggestionList({
    super.key,
    required this.items,
    required this.onSelect,
    this.title = 'সাজেশন',
  });

  final List<String> items;
  final ValueChanged<String> onSelect;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            child: Text(
              '$title (${items.length})',
              style: text.labelSmall,
            ),
          ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: line, indent: 18, endIndent: 18),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(items[i]);
                },
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(0) : Radius.zero,
                  bottom: i == items.length - 1
                      ? const Radius.circular(28)
                      : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: lavender,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person, color: ink, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          items[i],
                          style: text.titleMedium?.copyWith(fontSize: 15),
                        ),
                      ),
                      const Icon(Icons.north_west, color: textMuted, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
