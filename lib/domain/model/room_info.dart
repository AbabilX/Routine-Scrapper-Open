import 'class_slot.dart';

class RoomInfo {
  const RoomInfo({
    required this.roomName,
    required this.building,
    required this.isEmpty,
    required this.daySlots,
    this.currentOccupant,
    this.nextOccupant,
  });

  final String roomName;
  final String building;
  final bool isEmpty;
  final List<ClassSlot> daySlots;
  final ClassSlot? currentOccupant;
  final ClassSlot? nextOccupant;

  static String deriveBuilding(String roomName) {
    final upper = roomName.toUpperCase();
    if (upper.startsWith('KT')) return 'Knowledge Tower';
    if (upper.startsWith('ANX')) return 'Annex Building';
    if (upper.startsWith('G1')) return 'Main Building (G1)';
    if (upper.startsWith('SH')) return 'Short Hall';
    if (upper.startsWith('AB')) return 'Academic Building';
    return 'Campus Building';
  }
}

class TimeSlotOption {
  const TimeSlotOption(this.label, this.start, this.end);

  final String label;
  final String start;
  final String end;

  static const List<TimeSlotOption> predefined = [
    TimeSlotOption('08:30-10:00', '08:30', '10:00'),
    TimeSlotOption('10:00-11:30', '10:00', '11:30'),
    TimeSlotOption('11:30-01:00', '11:30', '01:00'),
    TimeSlotOption('01:00-02:30', '01:00', '02:30'),
    TimeSlotOption('02:30-04:00', '02:30', '04:00'),
    TimeSlotOption('04:00-05:30', '04:00', '05:30'),
  ];
}
