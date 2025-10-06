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
import 'package:lumeno_app/pages/login_page.dart';
import 'package:lumeno_app/pages/become_seller_page.dart';
import 'package:lumeno_app/pages/nearby_products_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // We'll manage the User object locally based on auth state changes
  // and use it in the build method.

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // No need to pushReplacement here, the StreamBuilder in main.dart
      // or at a higher level will handle navigation to LoginPage.
      // This HomePage widget will be rebuilt with a null user,
      // and the top-level auth check will redirect.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder to listen to authentication state changes.
    // This is the most robust way to ensure we always have the correct
    // User object or know when they are logged out.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final User? user = snapshot.data; // The current user (can be null)

        if (user == null) {
          // If user is null, they are not logged in.
          // Redirect to the login page. This handles cases where user logs out
          // or is not authenticated when HomePage is first displayed.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          });
          return const Scaffold(
            body: Center(child: Text('Redirecting to login...')),
          );
        }

        // Now, inside this scope, 'user' is guaranteed to be non-null.
        // We can safely use user.uid without the '!' operator or null checks.

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text("LUMENO"),
            backgroundColor: Colors.green.shade800,
            foregroundColor: Colors.white,
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
                    MaterialPageRoute(builder: (context) => const NearbyProductsPage()),
                  );
                },
                icon: const Icon(Icons.location_on_outlined),
                tooltip: 'Nearby Products',
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
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.green.shade800,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        user.displayName ?? 'LUMENO USER', // Use user's display name or a default
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? 'No email available', // Use user's email or a default
                        style: TextStyle(color: Colors.grey[200], fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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
                // Dynamic Seller Link based on user's 'isSeller' status
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        leading: Icon(Icons.store),
                        title: Text('Loading Seller Status...'),
                      );
                    }
                    if (snapshot.hasError) {
                      return const ListTile(
                        leading: Icon(Icons.error),
                        title: Text('Error loading status'),
                      );
                    }
                    final userData = snapshot.data?.data() as Map<String, dynamic>?;
                    final bool isSeller = userData?['isSeller'] ?? false;

                    if (isSeller) {
                      return ListTile(
                        leading: const Icon(Icons.store),
                        title: const Text('Seller Dashboard'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SellerDashboardPage()),
                          );
                        },
                      );
                    } else {
                      return ListTile(
                        leading: const Icon(Icons.store_mall_directory),
                        title: const Text('Become a Seller'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BecomeSellerPage()),
                          );
                        },
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.pop(context);
                    signOut();
                  },
                ),
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
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const SizedBox();
                    }
                    final userData = snapshot.data?.data() as Map<String, dynamic>?;
                    final bool isSeller = userData?['isSeller'] ?? false;

                    if (isSeller) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                          builder: (context) => const SellerDashboardPage(initialTabIndex: 0)),
                                    );
                                  },
                                  child: const SellerDashboardCard(icon: Icons.list_alt, label: 'My Products'),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SellerDashboardPage(initialTabIndex: 1)),
                                    );
                                  },
                                  child: const SellerDashboardCard(icon: Icons.shopping_bag, label: 'Orders'),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SellerDashboardPage(initialTabIndex: 2)),
                                    );
                                  },
                                  child: const SellerDashboardCard(icon: Icons.analytics, label: 'Analytics'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),

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
                            // Since 'user' is guaranteed non-null in this scope,
                            // we can directly use 'user.uid'.
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('cart')
                                .doc(productId)
                                .set({
                              'name': productData['name'],
                              'price': productData['price'],
                              'imageUrl': productData['imageUrl'],
                              'sellerId': productData['sellerId'],
                              'quantity': 1,
                            }, SetOptions(merge: true));

                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Added to cart')));
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
      }, // End of StreamBuilder builder function
    ); // End of StreamBuilder
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
    final String sellerName = product['sellerName'] ?? 'Local Artisan';
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
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // print('Error loading image: $exception');
                          },
                        )),
                    child: imageUrl.isEmpty
                        ? const Center(
                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey))
                        : null,
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Favorite functionality coming soon!')),
                          );
                        },
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
                  Text('By $sellerName',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ElevatedButton(
                        onPressed: addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
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