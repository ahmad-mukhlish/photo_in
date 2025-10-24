import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_in_app/routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
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

    isLoading.value = true;

    try {
      // Fake network delay to mimic auth call while backend is not ready yet.
      await Future<void>.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppPages.home);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
