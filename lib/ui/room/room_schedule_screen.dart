import 'package:diu/domain/model/student_summary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/model/routine_day.dart';
import '../../domain/room_queries.dart';
import '../../domain/routine_queries.dart';
import '../student/student_view_model.dart';
import '../theme/app_colors.dart';

class RoomScheduleScreen extends StatefulWidget {
  const RoomScheduleScreen({super.key});

  @override
  State<RoomScheduleScreen> createState() => _RoomScheduleScreenState();
}

class _RoomScheduleScreenState extends State<RoomScheduleScreen> {
  String _selectedRoom = '';
  RoutineDay _selectedDay = RoutineQueries.todayOrSaturday();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentViewModel>();
    final slots = viewModel.repository.slots;
    final allRooms = RoomQueries.allRooms(slots);

    final roomSchedule = _selectedRoom.isEmpty
        ? <ClassBlock>[]
        : RoomQueries.scheduleForRoom(slots, _selectedRoom, _selectedDay);

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

              // Room Autocomplete Input
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
                onSelected: (selection) {
                  setState(() => _selectedRoom = selection);
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (val) => setState(() => _selectedRoom = val),
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
                                    setState(() => _selectedRoom = '');
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

              // Day Selector Chips
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
                          if (selected) setState(() => _selectedDay = day);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Schedule Results
              Expanded(
                child: _selectedRoom.isEmpty
                    ? const Center(
                        child: Text(
                          'Type or select a room number above to see its classes',
                          style: TextStyle(color: textMuted, fontSize: 15),
                        ),
                      )
                    : roomSchedule.isEmpty
                    ? Center(
                        child: Text(
                          'No classes scheduled in $_selectedRoom on ${_selectedDay.fullLabel}',
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: roomSchedule.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        block.course,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: ink,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Group: ${block.group}  ·  Teacher: ${block.teacher}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
