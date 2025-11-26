import 'package:flutter/material.dart';

class DashboardPenyediaScreen extends StatelessWidget {
  const DashboardPenyediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Statistik"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Halaman Dashboard (Penyedia)"),
      ),
    );
  }
}