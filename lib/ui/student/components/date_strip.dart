import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/model/routine_day.dart';
import '../../theme/app_colors.dart';

class DayChip {
  const DayChip(this.day, this.date, this.isToday);

  final RoutineDay day;
  final int date;
  final bool isToday;
}

class DateStrip extends StatefulWidget {
  const DateStrip({
    super.key,
    required this.selected,
    required this.today,
    required this.onSelect,
  });

  final RoutineDay selected;
  final RoutineDay today;
  final ValueChanged<RoutineDay> onSelect;

  @override
  State<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<DateStrip> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
  }

  @override
  void didUpdateWidget(DateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.today != widget.today) {
      _scrollToToday();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToToday() {
    final chips = weekChips(widget.today);
    final index = chips
        .indexWhere((chip) => chip.isToday)
        .clamp(0, chips.length);
    if (!_scroll.hasClients) return;
    const itemExtent = 60.0;
    _scroll.animateTo(
      (index * itemExtent).clamp(0, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chips = weekChips(widget.today);
    return SizedBox(
      height: 82,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final active = chip.day == widget.selected;
          final circleColor = active
              ? ink
              : chip.isToday
              ? mint
              : line.withValues(alpha: 0.45);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onSelect(chip.day);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                      border: chip.isToday && !active
                          ? Border.all(
                              color: ink.withValues(alpha: 0.25),
                              width: 2,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${chip.date}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: active ? onInk : ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    chip.isToday ? 'আজ' : chip.day.shortLabel.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: active || chip.isToday ? ink : textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

List<DayChip> weekChips([
  RoutineDay today = RoutineDay.saturday,
  DateTime? now,
]) {
  final start = now ?? DateTime.now();
  final daysFromSaturday = _javaDayOfWeek(start) % 7;
  final saturday = DateTime(
    start.year,
    start.month,
    start.day - daysFromSaturday,
  );
  return [
    for (var i = 0; i < RoutineDay.values.length; i++)
      DayChip(
        RoutineDay.values[i],
        DateTime(saturday.year, saturday.month, saturday.day + i).day,
        RoutineDay.values[i] == today,
      ),
  ];
}

int _javaDayOfWeek(DateTime date) {
  return date.weekday == DateTime.sunday ? 1 : date.weekday + 1;
}
