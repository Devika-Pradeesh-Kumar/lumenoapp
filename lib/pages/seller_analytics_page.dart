// lib/pages/seller_analytics_page.dart

import 'package:flutter/material.dart';

class SellerAnalyticsPage extends StatelessWidget {
  const SellerAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Analytics coming soon!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              'Here, you will find insights into your sales, product performance, and more.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}