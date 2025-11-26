import 'package:flutter/material.dart';

class IklanPenyediaScreen extends StatelessWidget {
  const IklanPenyediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Iklan"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Halaman Iklan/Promosi (Penyedia)"),
      ),
    );
  }
}