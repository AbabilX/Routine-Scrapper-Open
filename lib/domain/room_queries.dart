import 'package:diu/domain/model/student_summary.dart';

import 'model/class_slot.dart';
import 'model/room_info.dart';
import 'model/routine_day.dart';
import 'routine_queries.dart';

class RoomQueries {
  static List<String> allRooms(List<ClassSlot> slots) {
    final set = <String>{};
    for (final slot in slots) {
      final name = slot.room.trim();
      if (name.isNotEmpty) {
        set.add(name);
      }
    }
    final sorted = set.toList()
      ..sort((a, b) {
        final bA = RoomInfo.deriveBuilding(a);
        final bB = RoomInfo.deriveBuilding(b);
        final comp = bA.compareTo(bB);
        if (comp != 0) return comp;
        return a.compareTo(b);
      });
    return sorted;
  }

  static List<RoomInfo> findEmptyRooms({
    required List<ClassSlot> slots,
    required RoutineDay day,
    TimeSlotOption? timeSlot,
    String? roomFilter,
    String? department,
  }) {
    final rooms = allRooms(slots);
    final query = (roomFilter ?? '').trim().toLowerCase();

    // Filter by department if specified and available
    final filteredSlots =
        (department != null && department.isNotEmpty && department != 'All')
        ? slots
        : slots;

    final results = <RoomInfo>[];

    for (final roomName in rooms) {
      if (query.isNotEmpty && !roomName.toLowerCase().contains(query)) {
        continue;
      }

      final daySlots = filteredSlots
          .where((s) => s.day == day && s.room.trim() == roomName)
          .toList();

      bool isOccupied = false;
      ClassSlot? currentOccupant;
      ClassSlot? nextOccupant;

      if (timeSlot != null) {
        final startMin = RoutineQueries.minutes(timeSlot.start);
        final endMin = RoutineQueries.minutes(timeSlot.end);

        for (final slot in daySlots) {
          final slotStart = RoutineQueries.minutes(slot.start);
          final slotEnd = RoutineQueries.minutes(slot.end);

          if (!(slotEnd <= startMin || slotStart >= endMin)) {
            isOccupied = true;
            currentOccupant = slot;
            break;
          }
        }
      } else {
        // If no time slot is selected, check against current time if today
        final nowMin = RoutineQueries.nowMinutes();
        for (final slot in daySlots) {
          final slotStart = RoutineQueries.minutes(slot.start);
          final slotEnd = RoutineQueries.minutes(slot.end);

          if (nowMin >= slotStart && nowMin < slotEnd) {
            isOccupied = true;
            currentOccupant = slot;
          } else if (slotStart > nowMin &&
              (nextOccupant == null ||
                  slotStart < RoutineQueries.minutes(nextOccupant.start))) {
            nextOccupant = slot;
          }
        }
      }

      results.add(
        RoomInfo(
          roomName: roomName,
          building: RoomInfo.deriveBuilding(roomName),
          isEmpty: !isOccupied,
          daySlots: daySlots,
          currentOccupant: currentOccupant,
          nextOccupant: nextOccupant,
        ),
      );
    }

    // Sort: Empty rooms first, then by room name
    results.sort((a, b) {
      if (a.isEmpty != b.isEmpty) return a.isEmpty ? -1 : 1;
      return a.roomName.compareTo(b.roomName);
    });

    return results;
  }

  static List<ClassBlock> scheduleForRoom(
    List<ClassSlot> slots,
    String roomName,
    RoutineDay day,
  ) {
    final matched = slots
        .where((s) => s.day == day && s.room.trim() == roomName.trim())
        .toList();
    return RoutineQueries.merge(matched);
  }
}
