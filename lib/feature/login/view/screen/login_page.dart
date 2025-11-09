import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_in_app/feature/login/controller/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Column(
              children: [
                const SizedBox(height: 100,),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller : controller.userName,
                        decoration: const InputDecoration(hintText: "Username"),
                      ),
                      TextField(
                        controller : controller.password,
                        decoration: const InputDecoration(hintText: "Password"),
                      ),
                      const SizedBox(height: 8,),
                      SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {

                            },
                            style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0))),
                            child: const Text("Login"),
                          ))
                    ],
                  ),
                ),
              ],
            )));
  }
}
