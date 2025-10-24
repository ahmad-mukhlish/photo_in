import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../data/interceptors/auth_token_interceptor.dart';
import '../data/repositories/auth_repository.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<Dio>(
      Dio(
        BaseOptions(
          baseUrl: 'http://13.228.127.252:8114',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: const {
            Headers.contentTypeHeader: Headers.textPlainContentType,
          },
        ),
      ),
      permanent: true,
    );

    Get.put<AuthRepository>(
      AuthRepository(Get.find<Dio>()),
      permanent: true,
    );

    final dio = Get.find<Dio>();
    if (!dio.interceptors.any((interceptor) => interceptor is AuthTokenInterceptor)) {
      final interceptor = AuthTokenInterceptor(
        authRepository: Get.find<AuthRepository>(),
        dio: dio,
      );
      dio.interceptors.add(interceptor);
      Get.put<AuthTokenInterceptor>(interceptor, permanent: true);
    }
  }
}

