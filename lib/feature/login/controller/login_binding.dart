import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:photo_in_app/feature/login/controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginController());
  }
}