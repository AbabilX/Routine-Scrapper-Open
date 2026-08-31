class PdfWord {
  const PdfWord({
    required this.page,
    required this.y,
    required this.x,
    required this.text,
  });

  final int page;
  final double y;
  final double x;
  final String text;
}

class ExtractedPdfText {
  const ExtractedPdfText({required this.words, required this.pageWidth});

  final List<PdfWord> words;
  final double pageWidth;
}
