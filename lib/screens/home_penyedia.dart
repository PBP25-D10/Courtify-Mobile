// lib/screens/home_penyedia.dart

import 'package:flutter/material.dart';
import 'package:courtify_mobile/services/auth_service.dart';
// Pastikan import halaman login Anda
import 'package:courtify_mobile/screens/login_screen.dart';

class HomePenyediaScreen extends StatefulWidget {
  const HomePenyediaScreen({super.key});

  @override
  State<HomePenyediaScreen> createState() => _HomePenyediaScreenState();
}

class _HomePenyediaScreenState extends State<HomePenyediaScreen> {
  final AuthService _authService = AuthService();
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? name = await _authService.getCurrentUsername();
    setState(() {
      _username = name ?? 'Penyedia';
    });
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pop(); 
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Penyedia"),
        backgroundColor: Colors.teal, // Warna tema berbeda untuk Penyedia
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu sapaan Penyedia
            Card(
              elevation: 4,
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.store, size: 50, color: Colors.teal),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Halo Owner,", style: TextStyle(fontSize: 16)),
                        Text(
                          _username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal
                          ),
                        ),
                        const Chip(
                          label: Text('Role: Penyedia Lapangan'),
                          backgroundColor: Colors.teal,
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
             // Contoh menu untuk penyedia
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildMenuCard(Icons.sports_tennis, "Kelola Lapangan", Colors.teal),
                  _buildMenuCard(Icons.calendar_today, "Jadwal Booking", Colors.orange),
                  _buildMenuCard(Icons.monetization_on, "Laporan Keuangan", Colors.green),
                  _buildMenuCard(Icons.settings, "Pengaturan", Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String label, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Menu $label diklik")));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}