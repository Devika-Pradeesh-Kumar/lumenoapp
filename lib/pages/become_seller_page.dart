// lib/pages/become_seller_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BecomeSellerPage extends StatelessWidget {
  const BecomeSellerPage({super.key});

  Future<void> upgradeToSeller(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Find the user's document and update the isSeller field to true
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'isSeller': true});

    // Show a success message and go back
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Congratulations! You are now a seller.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Seller'),
        backgroundColor: Colors.green.shade800,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront_outlined, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                'Join Our Community of Sellers',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Start selling your unique products and services to a wider audience. Upgrade your account to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => upgradeToSeller(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Upgrade to a Seller Account', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}