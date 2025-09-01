// lib/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumeno_app/pages/checkout_page.dart'; // Add this line

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // Function to increment item quantity
  void incrementQuantity(String userId, String cartItemId) {
    final cartItemRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId);

    cartItemRef.update({'quantity': FieldValue.increment(1)});
  }

  // Function to decrement item quantity
  void decrementQuantity(String userId, String cartItemId, int currentQuantity) {
    final cartItemRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId);

    if (currentQuantity > 1) {
      // If quantity is more than 1, just decrement
      cartItemRef.update({'quantity': FieldValue.increment(-1)});
    } else {
      // If quantity is 1, remove the item completely
      cartItemRef.delete();
    }
  }

  // Function to remove item from cart
  void removeItem(String userId, String cartItemId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String? userId = user?.uid;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Cart'),
          backgroundColor: Colors.green.shade800,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('Please log in to see your cart.'),
        ),
      );
    }

    final cartCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart');

    return Scaffold(
      backgroundColor: Colors.grey[50], // Slightly lighter background
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.green.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty!',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some amazing products to get started.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!.docs;
          
          double totalPrice = 0;
          for (var item in cartItems) {
            final data = item.data() as Map<String, dynamic>;
            totalPrice += (data['price'] ?? 0) * (data['quantity'] ?? 0);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Padding around the list
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final data = item.data() as Map<String, dynamic>;
                    final int quantity = data['quantity'] ?? 0;

                    return Center( // Center the card
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 2, // Added a subtle elevation for depth
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Rounded corners
                        // Constrain the width of the card
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect( // Clip image to rounded rectangle
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  data['imageUrl'] ?? '',
                                  width: 70, // Slightly larger image
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? 'No Name',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Controls
                              Row(
                                mainAxisSize: MainAxisSize.min, // Make row take minimum space
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20), // Smaller icons
                                    color: Colors.grey[600],
                                    onPressed: () => userId != null ? decrementQuantity(userId, item.id, quantity) : null,
                                  ),
                                  Text(quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20), // Smaller icons
                                    color: Colors.grey[600],
                                    onPressed: () => userId != null ? incrementQuantity(userId, item.id) : null,
                                  ),
                                ],
                              ),
                              // Remove Button
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22), // Slightly larger delete icon
                                onPressed: () => userId != null ? removeItem(userId, item.id) : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total Price and Checkout Button
              Container(
                padding: const EdgeInsets.all(18.0), // Slightly more padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08), // Softer shadow
                      blurRadius: 10,
                      offset: const Offset(0, -2), // Shadow above
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)), // Rounded top corners
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total amount:', style: TextStyle(color: Colors.grey, fontSize: 14)), // Smaller text
                        const SizedBox(height: 4),
                        Text(
                          '₹${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 26, // Slightly larger total price
                            fontWeight: FontWeight.bold,
                            color: Colors.green, // Highlight total in green
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
  onPressed: () {
    // NEW: Navigate to the Checkout Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutPage()),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green.shade700,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  ),
  child: const Text('Proceed to Checkout'),
),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}