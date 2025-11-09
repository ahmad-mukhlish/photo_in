import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
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
                      const TextField(
                        decoration: InputDecoration(hintText: "Username"),
                      ),
                      const TextField(
                        decoration: InputDecoration(hintText: "Password"),
                      ),
                      const SizedBox(height: 8,),
                      SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {},
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
