import 'package:flutter/material.dart';

class ArtikelPenyediaScreen extends StatelessWidget {
  const ArtikelPenyediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Artikel & Berita"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Halaman Artikel (Penyedia)"),
      ),
    );
  }
}