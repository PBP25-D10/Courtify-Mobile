import 'package:flutter/material.dart';

class WishlistUserScreen extends StatelessWidget {
  const WishlistUserScreen({super.key});

  static const Color backgroundColor = Color(0xFF111827);
  static const Color cardColor = Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Wishlist"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Halaman Wishlist (User)",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
