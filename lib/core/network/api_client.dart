import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';
import '../di/injection_container.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(_AuthInterceptor());
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final response = await dio.get(path, queryParameters: queryParameters);
    return _extractData(response);
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    final response = await dio.post(path, data: data);
    return _extractData(response);
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    final response = await dio.patch(path, data: data);
    return _extractData(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await dio.delete(path);
    return _extractData(response);
  }

  /// Extracts the `data` field from the standardized backend envelope
  /// `{ "success": true, "data": ..., "timestamp": "..." }`
  dynamic _extractData(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final storage = sl<TokenStorage>();
    final token = storage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final storage = sl<TokenStorage>();
      final refreshToken = storage.refreshToken;

      if (refreshToken != null) {
        try {
          final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
          final response = await refreshDio.post('/auth/refresh', data: {
            'refreshToken': refreshToken,
          });

          final data = response.data is Map && response.data.containsKey('data')
              ? response.data['data']
              : response.data;

          await storage.saveTokens(
            accessToken: data['accessToken'],
            refreshToken: data['refreshToken'],
          );

          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer ${data['accessToken']}';
          final retryResponse = await refreshDio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          await storage.clear();
        }
      }
    }
    handler.next(err);
  }
}
