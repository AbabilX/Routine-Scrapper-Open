import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'asset_routine_repository.dart';

class PdfExporter {
  static Future<void> share({String fileName = 'CSE_Routine_V5.pdf'}) async {
    final bytes = await rootBundle.load(AssetRoutineRepository.pdfAsset);
    final dir = await getTemporaryDirectory();
    final out = File('${dir.path}/$fileName');
    await out.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      flush: true,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(out.path, mimeType: 'application/pdf')],
        title: 'Share routine PDF',
      ),
    );
  }
}
