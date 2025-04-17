/// Exception thrown when an API request fails.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? endpoint;
  final Map<String, dynamic>? data;
  
  ApiException({
    required this.message,
    this.statusCode,
    this.endpoint,
    this.data,
  });
  
  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Endpoint: $endpoint)';
  }
}
