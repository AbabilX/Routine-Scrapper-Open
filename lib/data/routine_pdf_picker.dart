import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'picked_pdf.dart';

/// System PDF picker. Supports Linux, macOS, Windows via FilePicker, and Android/iOS via SAF/FilePicker.
class RoutinePdfPicker {
  RoutinePdfPicker({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'com.ababilx.diu/pdf_picker';

  final MethodChannel _channel;

  Future<PickedPdf?> pick() async {
    if (!kIsWeb &&
        (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      return _pickWithFilePicker();
    }

    try {
      final raw = await _channel.invokeMethod<dynamic>('pickPdf');
      final result = PickedPdf.fromChannel(raw);
      if (result != null) return result;
      return await _pickWithFilePicker();
    } on MissingPluginException catch (_) {
      return _pickWithFilePicker();
    } on PlatformException catch (_) {
      return _pickWithFilePicker();
    }
  }

  Future<PickedPdf?> _pickWithFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.path != null && file.path!.isNotEmpty) {
        return PickedPdf(
          path: file.path!,
          name: file.name.isEmpty ? 'routine.pdf' : file.name,
        );
      }
    }
    return null;
  }
}
