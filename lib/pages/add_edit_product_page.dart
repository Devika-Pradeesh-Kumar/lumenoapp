// lib/pages/add_edit_product_page.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEditProductPage extends StatefulWidget {
  final Map<String, dynamic>? product; // Optional: for editing existing product
  final String? productId; // Optional: for editing existing product

  const AddEditProductPage({super.key, this.product, this.productId});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController(); // New field for stock

  String? _imageUrl;
  XFile? _pickedFile; // To store the picked image file
  Uint8List? _pickedImageBytes; // To store bytes for web preview
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _isEditing = true;
      _nameController.text = widget.product!['name'] ?? '';
      _descriptionController.text = widget.product!['description'] ?? '';
      _priceController.text = (widget.product!['price'] ?? 0.0).toString();
      _categoryController.text = widget.product!['category'] ?? '';
      _stockController.text = (widget.product!['stock'] ?? 0).toString();
      _imageUrl = widget.product!['imageUrl'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      setState(() {
        _pickedFile = image;
        if (kIsWeb) {
          image.readAsBytes().then((bytes) {
            setState(() {
              _pickedImageBytes = bytes;
            });
          });
        }
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedFile == null) {
      return _imageUrl; // If no new image picked, return existing URL
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to upload an image.')),
      );
      return null;
    }

    try {
      final fileName = '${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child('product_images').child(fileName);

      UploadTask uploadTask;
      if (kIsWeb) {
        final Uint8List imageData = await _pickedFile!.readAsBytes();
        uploadTask = storageRef.putData(imageData);
      } else {
        uploadTask = storageRef.putFile(File(_pickedFile!.path));
      }

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add/edit products.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrl = await _uploadImage();
      if (_pickedFile != null && imageUrl == null) {
        // If an image was picked but failed to upload
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed. Product was not saved.')),
        );
        setState(() { _isLoading = false; });
        return; // Stop execution
      }

      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'category': _categoryController.text.trim(),
        'stock': int.tryParse(_stockController.text.trim()) ?? 0,
        'imageUrl': imageUrl ?? '', // Use the URL, or an empty string if it's null
        'sellerId': currentUser.uid,
        'sellerName': currentUser.displayName ?? currentUser.email,
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': 37.7749,
        'longitude': -122.4194,
      };

      if (_isEditing) {
        await FirebaseFirestore.instance.collection('products').doc(widget.productId).update(productData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
      } else {
        await FirebaseFirestore.instance.collection('products').add(productData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add New Product'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _pickedImageBytes != null
                            ? MemoryImage(_pickedImageBytes!)
                            : (_pickedFile != null && !kIsWeb
                                ? FileImage(File(_pickedFile!.path))
                                : (_imageUrl != null && _imageUrl!.isNotEmpty
                                    ? NetworkImage(_imageUrl!)
                                    : null)) as ImageProvider?,
                        child: _pickedFile == null && (_imageUrl == null || _imageUrl!.isEmpty)
                            ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade600)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product price';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product category';
                        }
                        return null;
                      },
                    ),
                     const SizedBox(height: 15),
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        if (int.tryParse(value) == null || int.parse(value) < 0) {
                          return 'Please enter a valid number for stock';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(_isEditing ? 'Update Product' : 'Add Product'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}