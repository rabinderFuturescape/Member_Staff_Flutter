import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'onessoauth_service.dart';

class ApiService {
  late Dio _dio;
  final OneSSOAuthService _oneSSOAuthService = OneSSOAuthService();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Constants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors for logging, etc.
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

    // Add interceptor for token refresh
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh it
            if (await _oneSSOAuthService.refreshToken()) {
              // Get the new token
              final newToken = await _oneSSOAuthService.getAccessToken();

              // Update the request header with the new token
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';

              // Create a new request with the updated header
              final opts = Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              );

              // Retry the request with the new token
              final response = await _dio.request(
                error.requestOptions.path,
                options: opts,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );

              // Return the response
              handler.resolve(response);
              return;
            }
          }

          // If token refresh failed or error is not 401, continue with the error
          handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      // If no token is provided, try to get it from OneSSOAuthService
      if (token == null) {
        token = await _oneSSOAuthService.getAccessToken();
      }

      final options = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      // If no token is provided, try to get it from OneSSOAuthService
      if (token == null) {
        token = await _oneSSOAuthService.getAccessToken();
      }

      final options = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      // If no token is provided, try to get it from OneSSOAuthService
      if (token == null) {
        token = await _oneSSOAuthService.getAccessToken();
      }

      final options = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      // If no token is provided, try to get it from OneSSOAuthService
      if (token == null) {
        token = await _oneSSOAuthService.getAccessToken();
      }

      final options = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    String? token,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      // If no token is provided, try to get it from OneSSOAuthService
      if (token == null) {
        token = await _oneSSOAuthService.getAccessToken();
      }

      final options = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
        responseType: ResponseType.bytes,
        followRedirects: false,
      );

      await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: options,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException e) {
    if (e.response != null) {
      print('Dio error!');
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');
      print('HEADERS: ${e.response?.headers}');
    } else {
      print('Error sending request!');
      print(e.message);
    }
  }
}
