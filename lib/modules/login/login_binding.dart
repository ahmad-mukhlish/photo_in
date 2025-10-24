import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:photo_in_app/data/interceptors/auth_token_interceptor.dart';
import 'package:photo_in_app/data/repositories/auth_repository.dart';

import 'login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: 'http://13.228.127.252:8114',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: const {
            Headers.contentTypeHeader: Headers.textPlainContentType,
          },
        ),
      ),
      fenix: true,
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find()),
      fenix: true,
    );

    final dio = Get.find<Dio>();
    if (!Get.isRegistered<AuthTokenInterceptor>()) {
      final interceptor = AuthTokenInterceptor(
        authRepository: Get.find<AuthRepository>(),
        dio: dio,
      );
      dio.interceptors.add(interceptor);
      Get.put<AuthTokenInterceptor>(interceptor, permanent: true);
    }

    Get.lazyPut<LoginController>(() => LoginController(Get.find()));
  }
}
