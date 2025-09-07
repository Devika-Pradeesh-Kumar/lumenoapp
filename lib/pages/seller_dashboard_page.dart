// lib/pages/seller_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumeno_app/pages/add_product_page.dart';

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Dashboard')),
        body: const Center(child: Text('You must be logged in to view this page.')),
      );
    }

    // This query gets ONLY the products created by the current seller
    final productsQuery = FirebaseFirestore.instance
        .collection('products')
        .where('sellerId', isEqualTo: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: Colors.green.shade800,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'You have not added any products yet.\nTap the + button to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  leading: (product['imageUrl'] != null && product['imageUrl'] != '')
                      ? Image.network(product['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported, size: 50),
                  title: Text(product['name'] ?? 'No Name'),
                  subtitle: Text('Price: ₹${(product['price'] ?? 0).toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      // We can add editing functionality here later
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      // Floating button to add new products
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the "Add Product" page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
        }, // <--- THIS BRACE WAS MISSING
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add),
      ),
    );
  }
}