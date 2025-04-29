// test_page.dart
import 'package:flutter/material.dart';

class ConstantKiPage extends StatelessWidget {
  const ConstantKiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test')), 
      body: const Center(
        child: Text('Test Page'),
      ),
    );
  }
}
