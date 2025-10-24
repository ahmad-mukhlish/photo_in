import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  HomeController(this._authRepository);

  final AuthRepository _authRepository;
  final isProcessing = false.obs;

  Future<void> logout() async {
    if (isProcessing.value) {
      return;
    }

    isProcessing.value = true;
    try {
      await _authRepository.logout();
      Get.offAllNamed(Routes.login);
    } catch (e,s) {
      print("$e $s");
      Get.snackbar(
        'Logout failed',
        'Unable to log out. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }
}
