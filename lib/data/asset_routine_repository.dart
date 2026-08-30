import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/model/class_slot.dart';
import '../domain/model/routine_day.dart';
import '../domain/model/routine_meta.dart';
import 'local_routine_store.dart';
import 'routine_file_dto.dart';

class AssetRoutineRepository {
  AssetRoutineRepository._(this.meta, this.slots, {this.hasRoutine = true});

  final RoutineMeta meta;
  final List<ClassSlot> slots;
  final bool hasRoutine;

  static const assetPath = 'assets/routine/cse_summer_2026_v5.json';
  static const pdfAsset = 'assets/routine/cse_summer_2026_v5.pdf';

  static AssetRoutineRepository empty() {
    return AssetRoutineRepository._(
      const RoutineMeta(
        department: '',
        version: '',
        semester: '',
        effectiveFrom: '',
        sourcePdf: '',
      ),
      const [],
      hasRoutine: false,
    );
  }

  static AssetRoutineRepository fromFile(RoutineFileDto file) {
    return AssetRoutineRepository._(
      RoutineMeta(
        schemaVersion: file.meta.schemaVersion,
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
      hasRoutine: file.slots.isNotEmpty,
    );
  }

  static Future<RoutineFileDto> loadBundledFile() async {
    final raw = await rootBundle.loadString(assetPath);
    return RoutineFileDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<AssetRoutineRepository> load([LocalRoutineStore? store]) async {
    if (store != null) {
      final saved = await store.loadUser();
      if (saved == null) return AssetRoutineRepository.empty();
      if (saved.meta.origin == 'bundled') {
        return fromFile(await loadBundledFile());
      }
      return fromFile(saved);
    }
    return fromFile(await loadBundledFile());
  }
}
