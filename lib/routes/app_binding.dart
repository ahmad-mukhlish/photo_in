import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../data/repositories/auth_repository.dart';
import 'app_routes.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://13.228.127.252:8114',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: const {
          Headers.contentTypeHeader: Headers.textPlainContentType,
        },
      ),
    );

    Get.put<Dio>(dio, permanent: true);

    final authRepository = AuthRepository(dio);
    Get.put<AuthRepository>(authRepository, permanent: true);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['skip_auth'] == true) {
            return handler.next(options);
          }

          final accessToken = await authRepository.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers["Authorization"] = 'Bearer $accessToken';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final shouldAttemptRefresh = error.response?.statusCode == 401 &&
              error.requestOptions.extra['skip_auth'] != true &&
              error.requestOptions.extra['retry_attempted'] != true;

          if (!shouldAttemptRefresh) {
            handler.next(error);
            return;
          }

          try {
            await authRepository.refreshSession();

            final retryOptions = error.requestOptions;
            retryOptions.extra['retry_attempted'] = true;

            final response = await dio.fetch<dynamic>(retryOptions);
            handler.resolve(response);
          } catch (_) {
            await authRepository.logout();
            if (Get.currentRoute != Routes.login) {
              Get.offAllNamed(Routes.login);
            }
            handler.next(error);
          }
        },
      ),
    );
  }
}
