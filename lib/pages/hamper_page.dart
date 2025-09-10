import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HamperPage extends StatelessWidget {
  const HamperPage({super.key});

  // List of 5 hamper items
  final List<Map<String, dynamic>> hamperItems = const [
    {
      'name': 'Chocolate Hamper',
      'price': 499,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/your-project-id.appspot.com/o/chocolate_hamper.jpg?alt=media',
      'seller': 'Local Artisan',
      'rating': 4.5,
    },
    {
      'name': 'Fruit Hamper',
      'price': 599,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/your-project-id.appspot.com/o/fruit_hamper.jpg?alt=media',
      'seller': 'Local Artisan',
      'rating': 4.5,
    },
    {
      'name': 'Car Bouquet',
      'price': 799,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/your-project-id.appspot.com/o/car_bouquet.jpg?alt=media',
      'seller': 'Local Artisan',
      'rating': 4.5,
    },
    {
      'name': 'Customizable Hamper',
      'price': 699,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/your-project-id.appspot.com/o/customizable_hamper.jpg?alt=media',
      'seller': 'Local Artisan',
      'rating': 4.5,
    },
    {
      'name': 'Luxury Hamper',
      'price': 999,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/your-project-id.appspot.com/o/luxury_hamper.jpg?alt=media',
      'seller': 'Local Artisan',
      'rating': 4.8,
    },
  ];

  // Function to add product to cart
  void addToCart(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(product['name'])
            .set({
          'name': product['name'],
          'price': product['price'],
          'imageUrl': product['imageUrl'],
          'quantity': 1,
          'seller': product['seller'] ?? 'Local Artisan',
        });
        Fluttertoast.showToast(
            msg: '${product['name']} added to cart!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      } catch (e) {
        Fluttertoast.showToast(
            msg: 'Error adding to cart: $e',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Please log in first',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hamper Collection'),
        backgroundColor: Colors.green.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: hamperItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final product = hamperItems[index];
            return ProductCard(
              product: product,
              addToCart: () => addToCart(product),
            );
          },
        ),
      ),
    );
  }
}

// ProductCard widget
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback addToCart;

  const ProductCard({super.key, required this.product, required this.addToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product['imageUrl'],
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image, size: 50));
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('₹${product['price']}',
                    style: const TextStyle(fontSize: 12, color: Colors.green)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text('${product['rating']}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('ADD', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
