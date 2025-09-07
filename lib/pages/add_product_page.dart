// lib/pages/add_product_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Function to upload the image and save the product
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child('product_images/$fileName');

      // 1. Upload the image to Firebase Storage
      await storageRef.putFile(_imageFile!);
      final imageUrl = await storageRef.getDownloadURL();

      // 2. Save the product data to Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'imageUrl': imageUrl,
        'sellerId': user.uid, // Link the product to the seller
        'seller': user.email, // Optionally, store seller's email
        'rating': 4.5, // Default rating
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context); // Go back to the dashboard
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        backgroundColor: Colors.green.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap to select an image', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder(), prefixText: '₹'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Product', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}