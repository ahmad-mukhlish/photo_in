import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Photo In"),
          ),
          body: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) {
                return buildPhotoItem();
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.camera),
          ),
        ));
  }

  Widget buildPhotoItem() {
    return const Text("Test");
  }
}
