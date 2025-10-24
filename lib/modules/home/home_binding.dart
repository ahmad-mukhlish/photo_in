import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/post_repository.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostRepository>(() => PostRepository(Get.find<Dio>()));
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<AuthRepository>(),
        Get.find<PostRepository>(),
      ),
    );
  }
}
