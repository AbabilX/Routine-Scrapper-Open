import 'dart:convert';

import 'package:flutter/services.dart';

class CourseCatalog {
  CourseCatalog(this._names);

  static const assetPath = 'assets/routine/course_names.json';

  final Map<String, String> _names;
  static CourseCatalog? _cached;

  static Future<CourseCatalog> load() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _cached = CourseCatalog({
      for (final entry in decoded.entries) entry.key: entry.value as String,
    });
    return _cached!;
  }

  String? nameOf(String code) => _names[code];
}
