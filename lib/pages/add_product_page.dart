// lib/pages/add_product_page.dart

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
  String _name = "";
  String _description = "";
  double _price = 0;
  File? _imageFile;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Upload image
      final ref = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

      await ref.putFile(_imageFile!);
      final imageUrl = await ref.getDownloadURL();

      // Save product data
      await FirebaseFirestore.instance.collection("products").add({
        'name': _name,
        'description': _description,
        'price': _price,
        'imageUrl': imageUrl,
        'sellerId': user.uid,
        'seller': user.email ?? "Unknown Seller",
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Product Added!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product"), backgroundColor: Colors.green.shade800),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Product Name"),
                      validator: (val) => val!.isEmpty ? "Enter name" : null,
                      onSaved: (val) => _name = val!,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Description"),
                      onSaved: (val) => _description = val!,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Price"),
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val!.isEmpty ? "Enter price" : null,
                      onSaved: (val) => _price = double.parse(val!),
                    ),
                    const SizedBox(height: 12),
                    _imageFile == null
                        ? const Text("No image selected")
                        : Image.file(_imageFile!, height: 150),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Pick Image"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      child: const Text("Save Product"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
