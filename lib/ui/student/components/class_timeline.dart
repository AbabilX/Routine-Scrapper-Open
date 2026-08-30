import 'package:flutter/material.dart';

import '../../../domain/model/class_reminder.dart';
import '../../../domain/model/class_status.dart';
import '../../../domain/model/student_summary.dart';
import '../../../domain/reminder_rules.dart';
import '../../../domain/routine_queries.dart';
import '../../theme/app_colors.dart';

class ClassTimeline extends StatelessWidget {
  const ClassTimeline({
    super.key,
    required this.items,
    this.statuses = const {},
    this.reminderMinutes = const {},
    this.onReminderTap,
  });

  final List<TimelineItem> items;
  final Map<ClassBlock, ClassStatus> statuses;
  final Map<String, int> reminderMinutes;
  final ValueChanged<ClassBlock>? onReminderTap;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    var classIndex = 0;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is TimelineClass) {
        children.add(
          _ClassCard(
            block: item.block,
            tint: cardPastels[classIndex % cardPastels.length],
            status: statuses[item.block] ?? ClassStatus.later,
            reminderMinutes:
                reminderMinutes[ClassReminderId.fromBlock(item.block)],
            onReminderTap: onReminderTap,
          ),
        );
        classIndex += 1;
      } else if (item is TimelineBreak) {
        children.add(_BreakChip(item: item));
      }
      if (i < items.length - 1) {
        children.add(const SizedBox(height: 14));
      }
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.block,
    required this.tint,
    required this.status,
    this.reminderMinutes,
    this.onReminderTap,
  });

  final ClassBlock block;
  final Color tint;
  final ClassStatus status;
  final int? reminderMinutes;
  final ValueChanged<ClassBlock>? onReminderTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final faded = status == ClassStatus.done;
    return Opacity(
      opacity: faded ? 0.55 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(block.course, style: text.headlineSmall),
                  ),
                  if (onReminderTap != null)
                    _ReminderBell(
                      minutes: reminderMinutes,
                      start: block.start,
                      onTap: () => onReminderTap!(block),
                    ),
                  _StatusPill(
                    status: status,
                    ringTime: reminderMinutes == null
                        ? null
                        : ReminderRules.formatFireTime(
                            block.start,
                            reminderMinutes!,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _MetaRow(
                icon: Icons.schedule_outlined,
                text: '${block.start}  –  ${block.end}',
              ),
              const SizedBox(height: 12),
              _MetaRow(icon: Icons.place_outlined, text: block.room),
              const SizedBox(height: 12),
              Text(block.teacher, style: text.titleMedium),
              const SizedBox(height: 12),
              Text('Section ${block.group}', style: text.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderBell extends StatelessWidget {
  const _ReminderBell({
    required this.minutes,
    required this.start,
    required this.onTap,
  });

  final int? minutes;
  final String start;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = minutes != null;
    final ringTime = on ? ReminderRules.formatFireTime(start, minutes!) : null;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: on ? 'রিং $ringTime' : 'রিমাইন্ডার',
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              on
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              size: 22,
              color: ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, this.ringTime});

  final ClassStatus status;
  final String? ringTime;

  @override
  Widget build(BuildContext context) {
    final (String? label, Color? color) = switch (status) {
      ClassStatus.now => ('এখন', mint),
      ClassStatus.next => (ringTime ?? 'পরের', sky),
      ClassStatus.done => ('শেষ', ink.withValues(alpha: 0.18)),
      ClassStatus.later => (ringTime, sky),
    };
    if (label == null) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: status == ClassStatus.done ? textMuted : ink,
          ),
        ),
      ),
    );
  }
}

class _BreakChip extends StatelessWidget {
  const _BreakChip({required this.item});

  final TimelineBreak item;

  @override
  Widget build(BuildContext context) {
    final label = RoutineQueries.formatDuration(item.minutes);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: mint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Text(
          '$label break  ·  ${item.start} – ${item.end}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ink),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: textMuted),
        ),
      ],
    );
  }
}
