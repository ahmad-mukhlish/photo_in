import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/storage_keys.dart';
import 'routes/app_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialRoute = await _determineInitialRoute();
  runApp(PhotoInApp(initialRoute: initialRoute));
}

class PhotoInApp extends StatelessWidget {
  const PhotoInApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Photo In App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      initialBinding: AppBinding(),
      getPages: AppPages.routes,
    );
  }
}

Future<String> _determineInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString(StorageKeys.accessToken);
  final refreshToken = prefs.getString(StorageKeys.refreshToken);

  if ((accessToken?.isNotEmpty ?? false) && (refreshToken?.isNotEmpty ?? false)) {
    return Routes.home;
  }

  return AppPages.initial;
}
