import 'package:flutter/material.dart';

class ParentModeScreen extends StatelessWidget {
  const ParentModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parent Mode")),
      body: const Center(child: Text("Parent Mode Screen")),
    );
  }
}