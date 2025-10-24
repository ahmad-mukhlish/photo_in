import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';

void main() {
  runApp(const PhotoInApp());
}

class PhotoInApp extends StatelessWidget {
  const PhotoInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Photo In App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
