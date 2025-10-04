import 'package:flutter/material.dart';

class SellerOrdersPage extends StatelessWidget {
  const SellerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seller Orders"), backgroundColor: Colors.green.shade800),
      body: const Center(child: Text("Orders Page")),
    );
  }
}
