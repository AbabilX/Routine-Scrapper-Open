import 'package:flutter/services.dart';

import 'picked_pdf.dart';

/// System PDF picker. Android uses Kotlin SAF in [MainActivity].
class RoutinePdfPicker {
  RoutinePdfPicker({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'com.ababilx.diu/pdf_picker';

  final MethodChannel _channel;

  Future<PickedPdf?> pick() async {
    final raw = await _channel.invokeMethod<dynamic>('pickPdf');
    return PickedPdf.fromChannel(raw);
  }
}
