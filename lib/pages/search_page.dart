import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search products...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.trim().toLowerCase(); // ✅ always lowercase
            });
          },
        ),
      ),
      body: searchQuery.isEmpty
          ? const Center(child: Text("Type something to search"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('searchName', isGreaterThanOrEqualTo: searchQuery)
                  .where('searchName', isLessThan: '$searchQuery\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // 🔹 fallback for old products without "searchName"
                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('products')
                        .get(),
                    builder: (context, snap) {
                      if (!snap.hasData || snap.data!.docs.isEmpty) {
                        return const Center(child: Text("No products found"));
                      }

                      final results = snap.data!.docs.where((doc) {
                        final name =
                            (doc['name'] ?? "").toString().toLowerCase();
                        return name.contains(searchQuery);
                      }).toList();

                      if (results.isEmpty) {
                        return const Center(child: Text("No products found"));
                      }

                      return ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final product =
                              results[index].data() as Map<String, dynamic>;
                          final productId = results[index].id;

                          return ListTile(
                            leading: Image.network(
                              product['imageUrl'] ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(product['name'] ?? 'No Name'),
                            subtitle: Text("₹${product['price'] ?? 0}"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(
                                    product: product,
                                    productId: productId,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }

                final products = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product =
                        products[index].data() as Map<String, dynamic>;
                    final productId = products[index].id;

                    return ListTile(
                      leading: Image.network(
                        product['imageUrl'] ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product['name'] ?? 'No Name'),
                      subtitle: Text("₹${product['price'] ?? 0}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              product: product,
                              productId: productId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
