import 'package:dio/dio.dart';
import '../utils/constants.dart';

class ApiService {
  late Dio _dio;

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
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
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
