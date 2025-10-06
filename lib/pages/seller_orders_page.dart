// lib/pages/seller_orders_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class SellerOrdersPage extends StatelessWidget {
  const SellerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Please log in as a seller to view orders.'));
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Fetch orders where one of the items belongs to the current seller
        // This query requires a specific Firestore structure.
        // A more robust solution might involve:
        // 1. Storing 'sellerId' directly on the 'order' document for quick query.
        // 2. Or, iterating through order items to check sellerId (less efficient).
        // For simplicity, we'll assume 'orders' documents will contain sellerId if relevant,
        // or we'll filter client-side for now (not ideal for large datasets).

        // For this example, let's assume each order item directly includes 'sellerId'
        // or a simple 'sellerId' field exists on the top-level order document.
        // A direct query on 'sellerId' in the order collection is often the most efficient.
        // If an order can contain items from multiple sellers,
        // the query becomes more complex (e.g., storing a list of seller IDs on the order).

        // Let's go with a simpler model for now: an order is associated with a single seller OR
        // we'll filter after fetching (less efficient but works for small scale).
        // BEST: When an order is created, create multiple order documents (one per seller involved)
        // or add an array of affected seller IDs to the order doc.

        // For demonstration, let's fetch all orders and filter client-side.
        // In a real app, optimize this Firestore query significantly!
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final allOrders = snapshot.data!.docs;
          final List<DocumentSnapshot> sellerOrders = [];

          // Filter orders to only show those relevant to this seller
          for (var orderDoc in allOrders) {
            final orderData = orderDoc.data() as Map<String, dynamic>;
            final List<dynamic> items = orderData['items'] ?? [];
            bool hasSellerProduct = false;
            for (var item in items) {
              // Assuming each item in the order has a 'sellerId' field
              if (item['sellerId'] == currentUser.uid) {
                hasSellerProduct = true;
                break;
              }
            }
            if (hasSellerProduct) {
              sellerOrders.add(orderDoc);
            }
          }

          if (sellerOrders.isEmpty) {
            return const Center(
              child: Text(
                'No orders received for your products yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: sellerOrders.length,
            itemBuilder: (context, index) {
              final orderDoc = sellerOrders[index];
              final orderData = orderDoc.data() as Map<String, dynamic>;
              final orderId = orderDoc.id;
              final timestamp = (orderData['timestamp'] as Timestamp?)?.toDate();
              final status = orderData['status'] ?? 'Pending';
              final totalAmount = orderData['totalAmount'] ?? 0.0;
              final customerEmail = orderData['customerEmail'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 2,
                child: ExpansionTile(
                  title: Text('Order ID: ${orderId.substring(0, 6)}...'),
                  subtitle: Text(
                    'Customer: $customerEmail\n'
                    'Date: ${timestamp != null ? DateFormat('dd MMM yyyy').format(timestamp) : 'N/A'}\n'
                    'Status: $status',
                  ),
                  trailing: Text('₹${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ..._buildOrderItemsList(orderData['items'] ?? [], currentUser.uid),
                          const Divider(),
                          Text('Shipping Address: ${orderData['shippingAddress'] ?? 'N/A'}'),
                          const SizedBox(height: 10),
                          _buildStatusDropdown(context, orderId, status),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildOrderItemsList(List<dynamic> items, String currentSellerId) {
    return items.where((item) => item['sellerId'] == currentSellerId).map((item) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
        child: Text('${item['name']} x${item['quantity']} - ₹${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
      );
    }).toList();
  }

  Widget _buildStatusDropdown(BuildContext context, String orderId, String currentStatus) {
    final List<String> statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
    return Row(
      children: [
        const Text('Update Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: currentStatus,
          onChanged: (String? newValue) {
            if (newValue != null) {
              _updateOrderStatus(context, orderId, newValue);
            }
          },
          items: statuses.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _updateOrderStatus(BuildContext context, String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order $orderId status updated to $newStatus!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order status: $e')),
      );
    }
  }
}