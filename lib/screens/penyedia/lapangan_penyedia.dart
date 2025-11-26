import 'package:flutter/material.dart';

class LapanganPenyediaScreen extends StatelessWidget {
  const LapanganPenyediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Lapangan"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Halaman Daftar Lapangan (Penyedia)"),
      ),
    );
  }
}