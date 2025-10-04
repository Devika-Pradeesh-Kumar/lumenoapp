// lib/pages/become_seller_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BecomeSellerPage extends StatefulWidget {
  const BecomeSellerPage({super.key});

  @override
  State<BecomeSellerPage> createState() => _BecomeSellerPageState();
}

class _BecomeSellerPageState extends State<BecomeSellerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _loading = false;

  Future<void> _submitSellerApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance.collection("sellers").doc(user.uid).set({
        "shopName": _shopNameController.text,
        "category": _categoryController.text,
        "description": _descriptionController.text,
        "phone": _phoneController.text,
        "verified": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Also update user profile with seller flag
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
        "isSeller": true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application submitted successfully!")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Become a Seller")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(labelText: "Shop Name"),
                validator: (v) => v!.isEmpty ? "Enter shop name" : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category"),
                validator: (v) => v!.isEmpty ? "Enter category" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submitSellerApplication,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Application"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
