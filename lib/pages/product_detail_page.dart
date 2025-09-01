// lib/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  // NEW: Add a field to receive the product's unique ID
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.productId, // NEW: Require the ID
  });

  // NEW: "Add to Cart" function
  Future<void> addToCart(BuildContext context) async {
    // Get the current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If no user is logged in, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to your cart.')),
      );
      return;
    }

    // Get a reference to the user's cart item
    final cartItemRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);

    // Use a transaction to safely handle adding the item
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(cartItemRef);

      if (!snapshot.exists) {
        // If the item is not in the cart, add it with quantity 1
        transaction.set(cartItemRef, {
          'name': product['name'],
          'price': product['price'],
          'imageUrl': product['imageUrl'],
          'quantity': 1,
        });
      } else {
        // If the item is already in the cart, just increase the quantity
        final newQuantity = snapshot.get('quantity') + 1;
        transaction.update(cartItemRef, {'quantity': newQuantity});
      }
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extracting data from the product map
    final String imageUrl = product['imageUrl'] ?? '';
    final String name = product['name'] ?? 'No Name Available';
    final String seller = product['seller'] ?? 'Local Artisan';
    final String description = product['description'] ?? 'No description available.';
    final num price = product['price'] ?? 0;
    final double rating = (product['rating'] ?? 4.5).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.green.shade800,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('By $seller', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(rating.toString(), style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('About this item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                  
                  // Price and Add to Cart Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      ElevatedButton(
                        // NEW: Call the addToCart function when pressed
                        onPressed: () => addToCart(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 207, 218, 208),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}