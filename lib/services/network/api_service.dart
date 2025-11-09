import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

class ApiService extends GetxService {
  ApiService({Dio? dio}) : _dio = dio ?? Dio(_defaultOptions);

  final Dio _dio;

  static BaseOptions get _defaultOptions {
    return BaseOptions(
      baseUrl: "",
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
    );
  }

  static ApiService get to => Get.find<ApiService>();
  Dio get client => _dio;

  Future<ApiService> init() async {
    return this;
  }

  Future<Response<T>> get<T>({
    String path = '',
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>({
    String path = '',
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>({
    String path = '',
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>({
    String path = '',
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
