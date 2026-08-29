import 'package:flutter/material.dart';

import '../../../domain/reminder_rules.dart';
import '../../theme/app_colors.dart';

class ReminderChoice {
  const ReminderChoice.off() : minutes = null;
  const ReminderChoice.minutes(this.minutes);

  final int? minutes;
}

String reminderLabel(int minutes) {
  return switch (minutes) {
    5 => '৫ মিনিট আগে',
    10 => '১০ মিনিট আগে',
    15 => '১৫ মিনিট আগে',
    20 => '২০ মিনিট আগে',
    30 => '৩০ মিনিট আগে',
    _ => '$minutes মিনিট আগে',
  };
}

Future<ReminderChoice?> showReminderPickerSheet({
  required BuildContext context,
  required String course,
  int? selected,
}) {
  return showModalBottomSheet<ReminderChoice>(
    context: context,
    backgroundColor: surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      // viewPadding survives SafeArea ancestors; padding.bottom is often 0
      // under Android 3-button / gesture nav when the sheet is edge-to-edge.
      final navInset = MediaQuery.viewPaddingOf(context).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(22, 18, 22, 20 + navInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(course, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'ক্লাসের কতক্ষণ আগে মনে করাবে?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _PresetChip(
                  label: 'বন্ধ',
                  selected: selected == null,
                  onTap: () => Navigator.pop(context, const ReminderChoice.off()),
                ),
                for (final minutes in ReminderRules.presets)
                  _PresetChip(
                    label: reminderLabel(minutes),
                    selected: selected == minutes,
                    onTap: () => Navigator.pop(
                      context,
                      ReminderChoice.minutes(minutes),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? mint : bg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
      ),
    );
  }
}
