class PickedPdf {
  const PickedPdf({required this.path, required this.name});

  final String path;
  final String name;

  static PickedPdf? fromChannel(Object? raw) {
    if (raw is! Map) return null;
    final path = raw['path']?.toString() ?? '';
    if (path.isEmpty) return null;
    final name = raw['name']?.toString().trim() ?? '';
    return PickedPdf(
      path: path,
      name: name.isEmpty ? 'routine.pdf' : name,
    );
  }
}
