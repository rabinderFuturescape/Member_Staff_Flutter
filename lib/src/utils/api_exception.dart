/// Exception thrown when an API request fails.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? endpoint;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.endpoint,
    this.data,
  });

  @override
  String toString() {
    String result = 'ApiException: $message';
    if (statusCode != null) {
      result += ' (Status Code: $statusCode)';
    }
    if (endpoint != null) {
      result += ' - Endpoint: $endpoint';
    }
    return result;
  }

  /// Returns a user-friendly error message.
  String get userFriendlyMessage {
    if (statusCode == 401) {
      return 'Your session has expired. Please log in again.';
    } else if (statusCode == 403) {
      return 'You do not have permission to perform this action.';
    } else if (statusCode == 404) {
      return 'The requested resource was not found.';
    } else if (statusCode == 500) {
      return 'An error occurred on the server. Please try again later.';
    } else if (statusCode == 503) {
      return 'The service is temporarily unavailable. Please try again later.';
    } else {
      return message;
    }
  }
}
