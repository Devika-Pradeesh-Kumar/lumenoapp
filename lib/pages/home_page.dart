// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumeno_app/pages/profile_page.dart';
import 'package:lumeno_app/pages/product_detail_page.dart';
import 'package:lumeno_app/pages/cart_page.dart';
import 'package:lumeno_app/pages/order_history_page.dart';
import 'package:lumeno_app/pages/search_page.dart';
import 'package:lumeno_app/pages/hamper_page.dart';
import 'package:lumeno_app/pages/seller_dashboard_page.dart';
import 'package:lumeno_app/pages/seller_orders_page.dart';
import 'package:lumeno_app/pages/seller_analytics_page.dart';
import 'package:lumeno_app/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSeller = false;
  bool _loading = true;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkSeller();
  }

  Future<void> _checkSeller() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(user!.uid)
          .get();

      setState(() {
        _isSeller = doc.exists;
        _loading = false;
      });
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("LUMENO"),
        backgroundColor: Colors.green.shade200,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 23, 36, 24)),
              child: Text('LUMENO MENU',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('MY PROFILE'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('ORDER HISTORY'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrderHistoryPage()));
              },
            ),
            const Divider(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promo Banner
            Container(
              margin: const EdgeInsets.all(16.0),
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                image: const DecorationImage(
                  image: AssetImage('assets/promo_banner.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Categories
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('SHOP BY CATEGORY',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const HamperPage()));
                    },
                    child: const CategoryIcon(icon: Icons.card_giftcard, label: 'Hamper'),
                  ),
                  const CategoryIcon(icon: Icons.brush, label: 'Handicrafts'),
                  const CategoryIcon(icon: Icons.checkroom, label: 'Clothing'),
                  const CategoryIcon(icon: Icons.eco, label: 'Organic'),
                  const CategoryIcon(icon: Icons.miscellaneous_services, label: 'Services'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seller Mini Dashboard
            if (_isSeller) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Seller Dashboard',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SellerDashboardPage()),
                        );
                      },
                      child: const SellerDashboardCard(icon: Icons.add_box, label: 'Add Product'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SellerDashboardPage()),
                        );
                      },
                      child: const SellerDashboardCard(icon: Icons.list_alt, label: 'My Products'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SellerOrdersPage()),
                        );
                      },
                      child: const SellerDashboardCard(icon: Icons.shopping_bag, label: 'Orders'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SellerAnalyticsPage()),
                        );
                      },
                      child: const SellerDashboardCard(icon: Icons.analytics, label: 'Analytics'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Trending Products
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('TRENDING PRODUCTS',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('View All'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').limit(8).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                final products = snapshot.data!.docs;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final productData = products[index].data() as Map<String, dynamic>;
                    final productId = products[index].id;

                    return ProductCard(
                      product: productData,
                      productId: productId,
                      addToCart: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('cart')
                              .doc(productId)
                              .set({
                            'name': productData['name'],
                            'price': productData['price'],
                            'imageUrl': productData['imageUrl'],
                            'quantity': 1,
                          }, SetOptions(merge: true));

                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Added to cart')));
                        }
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// Category Icon Widget
class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const CategoryIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 30, color: Colors.green.shade800),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// Seller Mini Dashboard Card
class SellerDashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const SellerDashboardCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.green.shade800),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green.shade900)),
        ],
      ),
    );
  }
}

// Product Card Widget
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String productId;
  final VoidCallback addToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.productId,
    required this.addToCart,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = product['imageUrl'] ?? '';
    final String name = product['name'] ?? 'No Name';
    final String seller = product['seller'] ?? 'Local Artisan';
    final num price = product['price'] ?? 0;
    final double rating = (product['rating'] ?? 4.5).toDouble();

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProductDetailPage(product: product, productId: productId)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(15.0)),
                        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: IconButton(
                        iconSize: 15,
                        icon: const Icon(Icons.favorite_border, color: Colors.grey),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 2),
                      Text(rating.toString()),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('By $seller',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ElevatedButton(
                        onPressed: addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 236, 230, 230),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('ADD', style: TextStyle(fontSize: 14)),
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
