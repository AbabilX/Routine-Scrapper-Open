import 'dart:typed_data';

import 'package:pdfrx/pdfrx.dart';

import 'pdf_word.dart';

class PdfWordExtractor {
  static Future<ExtractedPdfText> extract(Uint8List bytes) async {
    final doc = await PdfDocument.openData(bytes);
    try {
      final words = <PdfWord>[];
      var pageWidth = 1300.0;
      for (var i = 0; i < doc.pages.length; i++) {
        final page = await doc.pages[i].ensureLoaded();
        if (i == 0) pageWidth = page.width;
        final text = await page.loadStructuredText();
        words.addAll(_tokensForPage(i, page.height, text));
      }
      return ExtractedPdfText(words: _mergeNeighbors(words), pageWidth: pageWidth);
    } finally {
      await doc.dispose();
    }
  }

  static List<PdfWord> _tokensForPage(int page, double pageHeight, PdfPageText text) {
    final tokens = <PdfWord>[];
    for (final fragment in text.fragments) {
      final raw = fragment.text.trim();
      if (raw.isEmpty) continue;
      final y = pageHeight - fragment.bounds.top;
      tokens.add(
        PdfWord(
          page: page,
          y: y,
          x: fragment.bounds.left,
          text: raw,
        ),
      );
    }
    return tokens;
  }

  /// Glue split tokens like `CSE114` + `(68_C)` back together.
  static List<PdfWord> _mergeNeighbors(List<PdfWord> words) {
    if (words.length < 2) return words;
    final sorted = [...words]..sort((a, b) {
      final page = a.page.compareTo(b.page);
      if (page != 0) return page;
      final y = a.y.compareTo(b.y);
      if (y != 0) return y;
      return a.x.compareTo(b.x);
    });
    final merged = <PdfWord>[sorted.first];
    for (var i = 1; i < sorted.length; i++) {
      final prev = merged.last;
      final next = sorted[i];
      final sameLine = prev.page == next.page && (next.y - prev.y).abs() < 5;
      final close = next.x - prev.x < 90;
      final glue = sameLine &&
          close &&
          !prev.text.contains(' ') &&
          (next.text.startsWith('(') || prev.text.endsWith('('));
      if (glue) {
        merged[merged.length - 1] = PdfWord(
          page: prev.page,
          y: prev.y,
          x: prev.x,
          text: '${prev.text}${next.text}',
        );
      } else {
        merged.add(next);
      }
    }
    return merged;
  }
}
