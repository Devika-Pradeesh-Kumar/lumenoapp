// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final LocationService _ls = LocationService();
  Position? _position;
  String? _address;
  bool _loading = false;
  String? _error;

  Future<void> _getAndSaveLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final pos = await _ls.getCurrentPosition();
      final addr = await _ls.getAddressFromLatLng(pos.latitude, pos.longitude);

      // Save to Firestore (merge so it won't fail if doc doesn't exist)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'location': GeoPoint(pos.latitude, pos.longitude),
          'address': addr,
          'locationTs': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      setState(() {
        _position = pos;
        _address = addr;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _loading ? null : _getAndSaveLocation,
              icon: const Icon(Icons.my_location),
              label: Text(_loading ? 'Getting location...' : 'Get my location'),
            ),
            const SizedBox(height: 16),
            if (_position != null) ...[
              Text('Lat: ${_position!.latitude}'),
              Text('Lng: ${_position!.longitude}'),
            ],
            if (_address != null) Text('Address: $_address'),
            if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
