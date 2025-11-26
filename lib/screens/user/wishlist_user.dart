import 'package:flutter/material.dart';

class WishlistUserScreen extends StatelessWidget {
  const WishlistUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Halaman Wishlist (User)"),
      ),
    );
  }
}