import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/model/routine_day.dart';
import '../../domain/model/student_summary.dart';
import '../../domain/routine_queries.dart';
import '../components/cute_face_kind.dart';
import '../components/cute_header.dart';
import '../components/cute_page.dart';
import '../components/date_strip.dart';
import '../components/empty_hint.dart';
import '../components/search_row.dart';
import '../theme/app_colors.dart';
import 'room_view_model.dart';

class RoomScheduleScreen extends StatefulWidget {
  const RoomScheduleScreen({super.key});

  @override
  State<RoomScheduleScreen> createState() => _RoomScheduleScreenState();
}

class _RoomScheduleScreenState extends State<RoomScheduleScreen> {
  String _selectedRoom = '';
  RoutineDay _selectedDay = RoutineQueries.todayOrSaturday();

  void _selectRoom(String room) {
    setState(() => _selectedRoom = room);
    context.read<RoomViewModel>().loadRoomDay(room, _selectedDay);
  }

  void _selectDay(RoutineDay day) {
    setState(() => _selectedDay = day);
    if (_selectedRoom.isNotEmpty) {
      context.read<RoomViewModel>().loadRoomDay(_selectedRoom, day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RoomViewModel>();
    final state = viewModel.state;
    final allRooms = state.allRoomNames;
    final roomSchedule = RoutineQueries.merge(state.roomDaySlots);

    return CutePage(
      children: [
        const CuteHeader(
          title: 'রুম',
          subtitle: 'রুম নম্বর দিয়ে ক্লাস খুঁজে নাও',
          faceKind: CuteFaceKind.deer,
        ),
        const SizedBox(height: 18),
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return allRooms.take(8);
            }
            return allRooms.where(
              (room) => room.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ),
            );
          },
          onSelected: _selectRoom,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return SearchRow(
              query: controller.text,
              onQueryChange: (val) {
                controller.value = TextEditingValue(
                  text: val,
                  selection: TextSelection.collapsed(offset: val.length),
                );
                setState(() => _selectedRoom = val);
              },
              hintText: 'KT-201',
              onSubmitted: _selectRoom,
              trailing: controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                        _selectRoom('');
                      },
                      icon: const Icon(Icons.close, size: 18, color: textMuted),
                    )
                  : null,
            );
          },
        ),
        const SizedBox(height: 18),
        DateStrip(
          selected: _selectedDay,
          today: RoutineQueries.todayOrSaturday(),
          onSelect: _selectDay,
        ),
        const SizedBox(height: 18),
        _RoomResults(
          selectedRoom: _selectedRoom,
          selectedDay: _selectedDay,
          loading: state.scheduleLoading,
          roomSchedule: roomSchedule,
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _RoomResults extends StatelessWidget {
  const _RoomResults({
    required this.selectedRoom,
    required this.selectedDay,
    required this.loading,
    required this.roomSchedule,
  });

  final String selectedRoom;
  final RoutineDay selectedDay;
  final bool loading;
  final List<ClassBlock> roomSchedule;

  @override
  Widget build(BuildContext context) {
    if (selectedRoom.isEmpty) {
      return const EmptyHint(
        title: 'শুরু করো',
        body: 'উপরে রুম নম্বর লিখো বা বেছে নাও',
        tint: peach,
      );
    }
    if (loading) {
      return const EmptyHint(
        title: 'খুঁজছি',
        body: 'রুমের রুটিন আনছি…',
        tint: sky,
      );
    }
    if (roomSchedule.isEmpty) {
      return EmptyHint(
        title: 'ক্লাস নেই',
        body: '$selectedRoom — ${selectedDay.fullLabel}-এ ক্লাস নেই',
        tint: mint,
      );
    }

    return Column(
      children: [
        for (final block in roomSchedule) ...[
          _RoomClassCard(block: block),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _RoomClassCard extends StatelessWidget {
  const _RoomClassCard({required this.block});

  final ClassBlock block;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: lavender,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${block.start}\n${block.end}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: ink,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.courseTitle.isNotEmpty
                        ? block.courseTitle
                        : block.course,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    block.courseTitle.isNotEmpty
                        ? '${block.course} · ${block.group} · ${block.teacher}'
                        : '${block.group} · ${block.teacher}',
                    style: const TextStyle(fontSize: 13, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
