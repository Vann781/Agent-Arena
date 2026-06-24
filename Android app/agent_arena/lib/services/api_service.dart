import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/api_constants.dart';

class ApiService {
  late final Dio _dio;
  final String _sessionId;

  ApiService() : _sessionId = const Uuid().v4() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          ApiConstants.sessionIdHeader: _sessionId,
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );
  }

  String get sessionId => _sessionId;

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) =>
      _dio.get(path, queryParameters: queryParams);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);
}
