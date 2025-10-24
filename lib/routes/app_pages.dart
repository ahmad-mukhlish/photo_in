import 'package:get/get.dart';

import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_controller.dart';
import '../modules/login/login_view.dart';

class AppPages {
  AppPages._();

  static const login = '/login';
  static const home = '/home';

  static const initial = login;

  static final routes = <GetPage<dynamic>>[
    GetPage<LoginController>(
      name: login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: home,
      page: () => const HomeView(),
    ),
  ];
}
