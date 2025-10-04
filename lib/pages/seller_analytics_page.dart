import 'package:flutter/material.dart';

class SellerAnalyticsPage extends StatelessWidget {
  const SellerAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seller Analytics"), backgroundColor: Colors.green.shade800),
      body: const Center(child: Text("Analytics Page")),
    );
  }
}
