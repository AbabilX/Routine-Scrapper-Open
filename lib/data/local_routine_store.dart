import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'routine_file_dto.dart';

/// Device copies of the student's uploaded PDF and parsed JSON.
class LocalRoutineStore {
  static const jsonFileName = 'routine.json';
  static const pdfFileName = 'user_routine.pdf';

  Future<Directory> _dir() => getApplicationDocumentsDirectory();

  Future<File> jsonFile() async => File('${(await _dir()).path}/$jsonFileName');

  Future<File> pdfFile() async => File('${(await _dir()).path}/$pdfFileName');

  Future<RoutineFileDto?> loadUser() async {
    final file = await jsonFile();
    if (!await file.exists()) return null;
    try {
      final dto = RoutineFileDto.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, dynamic>,
      );
      if (dto.meta.origin != 'user' || dto.slots.isEmpty) return null;
      return dto;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser({
    required RoutineFileDto routine,
    required Uint8List pdfBytes,
  }) async {
    final json = await jsonFile();
    final pdf = await pdfFile();
    await json.writeAsString(
      const JsonEncoder.withIndent('  ').convert(routine.toJson()),
    );
    await pdf.writeAsBytes(pdfBytes, flush: true);
  }
}
