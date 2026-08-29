class RoutineMeta {
  const RoutineMeta({
    required this.department,
    required this.version,
    required this.semester,
    required this.effectiveFrom,
    required this.sourcePdf,
    this.schemaVersion = 1,
  });

  final int schemaVersion;
  final String department;
  final String version;
  final String semester;
  final String effectiveFrom;
  final String sourcePdf;

  String get fingerprint =>
      '$department|$version|$effectiveFrom|$schemaVersion';
}
