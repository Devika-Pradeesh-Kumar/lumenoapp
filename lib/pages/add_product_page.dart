import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  String _category = "";
  int _stockQuantity = 0;

  XFile? _pickedFile;
  Uint8List? _pickedImageBytes; // NEW: To store bytes for web preview

  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _pickedFile = picked;
          if (kIsWeb) {
            // NEW: Read bytes for web preview
            picked.readAsBytes().then((bytes) {
              setState(() {
                _pickedImageBytes = bytes;
              });
            });
          }
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: ${e.toString()}")),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select an image.")),
      );
      return;
    }
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in.")),
        );
        return;
      }

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${_pickedFile!.name}';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child(user.uid)
          .child(fileName);

      UploadTask uploadTask;
      if (kIsWeb) {
        final Uint8List imageData = await _pickedFile!.readAsBytes();
        uploadTask = ref.putData(imageData);
      } else {
        uploadTask = ref.putFile(File(_pickedFile!.path));
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String imageUrl = await snapshot.ref.getDownloadURL();

      String sellerName = user.displayName ?? user.email ?? "Unknown Seller";

      await FirebaseFirestore.instance.collection("products").add({
        'name': _name,
        'description': _description,
        'price': _price,
        'imageUrl': imageUrl,
        'sellerId': user.uid,
        'sellerName': sellerName,
        'category': _category,
        'stockQuantity': _stockQuantity,
        'createdAt': FieldValue.serverTimestamp(),
        'available': true,
        'rating': 0.0,
        'numReviews': 0,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Product Added!")));
      }
    } catch (e) {
      print('Error saving product: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error saving product: ${e.toString()}")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Product"),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Image Picker Section
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: _pickedFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 50, color: Colors.grey[600]),
                                  const SizedBox(height: 8),
                                  Text("Tap to pick image", style: TextStyle(color: Colors.grey[700])),
                                ],
                              )
                            // NEW conditional rendering for image preview
                            : kIsWeb && _pickedImageBytes != null
                                ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                                : Image.file(File(_pickedFile!.path), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product Name
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Product Name"),
                      validator: (val) => val!.isEmpty ? "Please enter a product name" : null,
                      onSaved: (val) => _name = val!,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      onSaved: (val) => _description = val!,
                    ),
                    const SizedBox(height: 12),

                    // Price
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Price (₹)"),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val!.isEmpty) return "Please enter a price";
                        if (double.tryParse(val) == null) return "Please enter a valid number";
                        if (double.parse(val) <= 0) return "Price must be greater than 0";
                        return null;
                      },
                      onSaved: (val) => _price = double.parse(val!),
                    ),
                    const SizedBox(height: 12),

                    // Category - Use a Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Category"),
                      value: _category.isEmpty ? null : _category,
                      hint: const Text("Select Category"),
                      items: const [
                        DropdownMenuItem(value: "Handicrafts", child: Text("Handicrafts")),
                        DropdownMenuItem(value: "Clothing", child: Text("Clothing")),
                        DropdownMenuItem(value: "Organic Food", child: Text("Organic Food")),
                        DropdownMenuItem(value: "Home Decor", child: Text("Home Decor")),
                        DropdownMenuItem(value: "Hampers", child: Text("Hampers")),
                        DropdownMenuItem(value: "Services", child: Text("Services")),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _category = newValue!;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty ? "Please select a category" : null,
                      onSaved: (val) => _category = val!,
                    ),
                    const SizedBox(height: 12),

                    // Stock Quantity
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Stock Quantity"),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val!.isEmpty) return "Please enter stock quantity";
                        if (int.tryParse(val) == null) return "Please enter a valid number";
                        if (int.parse(val) < 0) return "Quantity cannot be negative";
                        return null;
                      },
                      onSaved: (val) => _stockQuantity = int.parse(val!),
                    ),
                    const SizedBox(height: 20),

                    // Add Product Button
                    ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Add Product",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}