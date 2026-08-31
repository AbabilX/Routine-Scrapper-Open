class RoutineApiException implements Exception {
  const RoutineApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory RoutineApiException.http(int statusCode) {
    return RoutineApiException('HTTP $statusCode', statusCode: statusCode);
  }

  factory RoutineApiException.parse() {
    return const RoutineApiException('Invalid API response');
  }

  @override
  String toString() => message;
}
