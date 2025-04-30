// test_page.dart
import 'package:flutter/material.dart';

class AgeingPage extends StatelessWidget {
  const AgeingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ageing')), 
      body: const Center(
        child: Text('Ageing Page'),
      ),
    );
  }
}
