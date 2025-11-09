import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:photo_in_app/services/network/api_service.dart';

class LoginController extends GetxController{
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();

  void login(String username, String password) async {
    ApiService.to.get();
  }
}