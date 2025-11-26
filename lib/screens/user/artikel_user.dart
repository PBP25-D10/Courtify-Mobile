import 'package:flutter/material.dart';

class ArtikelUserScreen extends StatelessWidget {
  const ArtikelUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Artikel"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Halaman Baca Artikel (User)"),
      ),
    );
  }
}