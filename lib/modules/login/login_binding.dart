import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
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

    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()));
    Get.lazyPut<LoginController>(() => LoginController(Get.find()));
  }
}
