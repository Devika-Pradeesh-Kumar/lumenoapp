import 'package:flutter/material.dart';

class NearbyProductsPage extends StatelessWidget {
  const NearbyProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Products'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Content for Nearby Products will go here!'),
      ),
    );
  }
}