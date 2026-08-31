import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/model/student_summary.dart';
import '../../domain/model/routine_day.dart';
import '../../domain/routine_queries.dart';
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

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Room Routine Search',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Search schedule for any specific classroom or lab',
                style: TextStyle(fontSize: 14, color: textMuted),
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
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (val) {
                          setState(() => _selectedRoom = val);
                        },
                        onSubmitted: _selectRoom,
                        decoration: InputDecoration(
                          hintText: 'Enter Room Number (e.g. KT-201, 611)',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: textMuted,
                          ),
                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    controller.clear();
                                    _selectRoom('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: line),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: line),
                          ),
                        ),
                      );
                    },
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: RoutineDay.values.map((day) {
                    final isSelected = day == _selectedDay;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(day.shortLabel),
                        selected: isSelected,
                        selectedColor: ink,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : ink,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        backgroundColor: surface,
                        onSelected: (selected) {
                          if (selected) _selectDay(day);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: _results(state.scheduleLoading, roomSchedule)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _results(bool loading, List<ClassBlock> roomSchedule) {
    if (_selectedRoom.isEmpty) {
      return const Center(
        child: Text(
          'Type or select a room number above to see its classes',
          style: TextStyle(color: textMuted, fontSize: 15),
        ),
      );
    }
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (roomSchedule.isEmpty) {
      return Center(
        child: Text(
          'No classes scheduled in $_selectedRoom on ${_selectedDay.fullLabel}',
          style: const TextStyle(color: textMuted, fontSize: 15),
        ),
      );
    }
    return ListView.separated(
      itemCount: roomSchedule.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final block = roomSchedule[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: line),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: lavender.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${block.start}\n${block.end}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
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
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      block.courseTitle.isNotEmpty
                          ? '${block.course}  ·  Group: ${block.group}  ·  Teacher: ${block.teacher}'
                          : 'Group: ${block.group}  ·  Teacher: ${block.teacher}',
                      style: const TextStyle(fontSize: 13, color: textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
