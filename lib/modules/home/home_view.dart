import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Welcome to Photo In App'),
            const SizedBox(height: 24),
            Obx(
              () => FilledButton.icon(
                onPressed: controller.isProcessing.value ? null : controller.logout,
                icon: controller.isProcessing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: Text(
                  controller.isProcessing.value ? 'Logging out...' : 'Log out',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
