import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:photo_in_app/feature/login/controller/login_binding.dart';
import 'package:photo_in_app/feature/login/view/screen/login_page.dart';
import 'package:photo_in_app/routes/app_routes.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(name: AppRoutes.login, page : () => const LoginPage(), binding: LoginBinding())
  ];
}