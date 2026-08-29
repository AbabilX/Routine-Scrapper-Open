import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'routine_file_dto.dart';

/// Copies the bundled routine JSON onto the device so later updates
/// (download / PDF parse) can replace one file without touching domain code.
class LocalRoutineStore {
  LocalRoutineStore({this.assetPath = defaultAssetPath});

  static const defaultAssetPath = 'assets/routine/cse_summer_2026_v5.json';
  static const fileName = 'routine.json';

  final String assetPath;

  Future<String> loadOrSeed() async {
    final bundled = await rootBundle.loadString(assetPath);
    final local = await _localFile();
    if (!await local.exists()) {
      await local.writeAsString(bundled);
      return bundled;
    }

    final localRaw = await local.readAsString();
    if (_shouldReplaceWithBundled(bundled, localRaw)) {
      await local.writeAsString(bundled);
      return bundled;
    }
    return localRaw;
  }

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  bool _shouldReplaceWithBundled(String bundled, String localRaw) {
    try {
      final localDto = RoutineFileDto.fromJson(
        jsonDecode(localRaw) as Map<String, dynamic>,
      );
      if (localDto.meta.origin == 'user') return false;
      final bundledDto = RoutineFileDto.fromJson(
        jsonDecode(bundled) as Map<String, dynamic>,
      );
      return bundledDto.meta.fingerprint != localDto.meta.fingerprint;
    } catch (_) {
      return true;
    }
  }
}
