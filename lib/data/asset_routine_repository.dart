import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/model/class_slot.dart';
import '../domain/model/routine_day.dart';
import '../domain/model/routine_meta.dart';
import 'routine_file_dto.dart';

class AssetRoutineRepository {
  AssetRoutineRepository._(this.meta, this.slots);

  final RoutineMeta meta;
  final List<ClassSlot> slots;

  static const assetPath = 'assets/routine/cse_summer_2026_v5.json';
  static const pdfAsset = 'assets/routine/cse_summer_2026_v5.pdf';

  static Future<AssetRoutineRepository> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final file = RoutineFileDto.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    return AssetRoutineRepository._(
      RoutineMeta(
        department: file.meta.department,
        version: file.meta.version,
        semester: file.meta.semester,
        effectiveFrom: file.meta.effectiveFrom,
        sourcePdf: file.meta.sourcePdf,
      ),
      file.slots
          .map(
            (dto) => ClassSlot(
              day: RoutineDay.fromName(dto.day),
              slot: dto.slot,
              start: dto.start,
              end: dto.end,
              course: dto.course,
              group: dto.group,
              teacher: dto.teacher,
              room: dto.room,
            ),
          )
          .toList(),
    );
  }
}
