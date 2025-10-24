import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../network/dio_extra_keys.dart';
import '../repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class AuthTokenInterceptor extends QueuedInterceptorsWrapper {
  AuthTokenInterceptor({
    required AuthRepository authRepository,
    required Dio dio,
  })  : _authRepository = authRepository,
        _dio = dio;

  final AuthRepository _authRepository;
  final Dio _dio;

  Future<void>? _refreshFuture;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra[DioExtraKeys.skipAuth] == true) {
      handler.next(options);
      return;
    }

    final accessToken = await _authRepository.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldAttemptRefresh(err)) {
      handler.next(err);
      return;
    }

    try {
      await _refreshTokens();

      final retryOptions = err.requestOptions;
      retryOptions.extra[DioExtraKeys.retryAttempted] = true;

      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on AuthException catch (error) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: error,
          response: err.response,
          type: DioExceptionType.badResponse,
        ),
      );
    } on DioException catch (error) {
      handler.reject(error);
    } catch (error) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: error,
          response: err.response,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  bool _shouldAttemptRefresh(DioException err) {
    if (err.response?.statusCode != 401) {
      return false;
    }

    final options = err.requestOptions;
    if (options.extra[DioExtraKeys.skipAuth] == true) {
      return false;
    }

    if (options.extra[DioExtraKeys.retryAttempted] == true) {
      return false;
    }

    final method = options.method.toUpperCase();
    if (options.path == '/session' && (method == 'POST' || method == 'PUT')) {
      return false;
    }

    return true;
  }

  Future<void> _refreshTokens() {
    _refreshFuture ??= _attemptRefresh().whenComplete(() => _refreshFuture = null);
    return _refreshFuture!;
  }

  Future<void> _attemptRefresh() async {
    try {
      await _authRepository.refreshSession();
    } on AuthException {
      await _handleExpiredSession();
      rethrow;
    }
  }

  Future<void> _handleExpiredSession() async {
    await _authRepository.logout();
    if (Get.currentRoute != Routes.login) {
      Get.offAllNamed(Routes.login);
    }
  }
}
