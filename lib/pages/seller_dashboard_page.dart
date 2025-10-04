// lib/pages/seller_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:lumeno_app/pages/add_product_page.dart';
import 'package:lumeno_app/pages/seller_products_page.dart';

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Dashboard"),
        backgroundColor: Colors.green.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _DashboardCard(
  icon: Icons.add_box,
  title: "Add Product",
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddProductPage()),
  ),
),
_DashboardCard(
  icon: Icons.inventory,
  title: "My Products",
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SellerProductsPage()),
  ),
),

            _DashboardCard(
              icon: Icons.receipt_long,
              title: "Orders",
              onTap: () {
                // TODO: Add Seller Orders Page
              },
            ),
            _DashboardCard(
              icon: Icons.analytics,
              title: "Analytics",
              onTap: () {
                // TODO: Add Seller Analytics Page
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.green.shade50,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.green.shade800),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
