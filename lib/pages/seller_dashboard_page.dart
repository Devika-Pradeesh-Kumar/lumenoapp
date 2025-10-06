// lib/pages/seller_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:lumeno_app/pages/seller_products_page.dart';
import 'package:lumeno_app/pages/seller_orders_page.dart';
import 'package:lumeno_app/pages/seller_analytics_page.dart';

class SellerDashboardPage extends StatefulWidget {
  final int initialTabIndex; // New parameter

  const SellerDashboardPage({super.key, this.initialTabIndex = 0}); // Default to 0

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex); // Set initial index
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade300,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Products'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Orders'),
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SellerProductsPage(),
          SellerOrdersPage(),
          SellerAnalyticsPage(),
        ],
      ),
    );
  }
}