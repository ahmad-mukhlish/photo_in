import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_in_app/data/repositories/auth_repository.dart';
import 'package:photo_in_app/routes/app_pages.dart';

class LoginController extends GetxController {
  LoginController(this._authRepository);

  final AuthRepository _authRepository;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isObscured = true.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isObscured.toggle();
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      await _authRepository.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed(AppPages.home);
    } on AuthException catch (error, stacktrace) {
      Get.snackbar(
        'Login failed',
        "${error.message} $stacktrace",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error, stacktrace) {
      print("$error \n $stacktrace");

      Get.snackbar(
        'Login failed',
        '$error \n $stacktrace',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
