import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(Get.find<AuthRepository>()));
  }
}
