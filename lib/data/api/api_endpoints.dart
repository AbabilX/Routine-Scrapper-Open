/// Compile-time API path constants from `--dart-define-from-file=.env`.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String routineVersion = String.fromEnvironment(
    'API_PATH_ROUTINE_VERSION',
  );
  static const String autocomplete = String.fromEnvironment(
    'API_PATH_AUTOCOMPLETE',
  );
  static const String schedule = String.fromEnvironment('API_PATH_SCHEDULE');
  static const String freeRooms = String.fromEnvironment('API_PATH_FREE_ROOMS');
  static const String roomsStatic = String.fromEnvironment(
    'API_PATH_ROOMS_STATIC',
  );
  static const String teachersStatic = String.fromEnvironment(
    'API_PATH_TEACHERS_STATIC',
  );

  static bool get isConfigured =>
      routineVersion.trim().isNotEmpty &&
      autocomplete.trim().isNotEmpty &&
      schedule.trim().isNotEmpty &&
      freeRooms.trim().isNotEmpty &&
      roomsStatic.trim().isNotEmpty &&
      teachersStatic.trim().isNotEmpty;
}
