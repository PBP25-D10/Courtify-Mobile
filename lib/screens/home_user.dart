// lib/screens/home_user.dart

import 'package:flutter/material.dart';
import 'package:courtify_mobile/services/auth_service.dart';
// Pastikan import halaman login Anda
import 'package:courtify_mobile/screens/login_screen.dart'; 

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  final AuthService _authService = AuthService();
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Mengambil nama user dari penyimpanan lokal
  Future<void> _loadUserData() async {
    String? name = await _authService.getCurrentUsername();
    setState(() {
      _username = name ?? 'User';
    });
  }

  // Fungsi Logout
  void _handleLogout() async {
    // Tampilkan loading dialog (opsional, tapi bagus untuk UX)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Panggil service logout ke Django
    await _authService.logout();

    if (!mounted) return;
    // Tutup loading dialog
    Navigator.of(context).pop(); 

    // Navigasi kembali ke halaman Login dan HAPUS semua history navigasi sebelumnya
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
        title: const Text("Courtify - User Home"),
        backgroundColor: Colors.blue, // Warna tema untuk User
        actions: [
          // Tombol Logout di AppBar
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu sapaan
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 50, color: Colors.blue),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Selamat Datang,", style: TextStyle(fontSize: 16)),
                        Text(
                          _username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Chip(
                          label: Text('Role: User Biasa'),
                          backgroundColor: Colors.blueAccent,
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Menu Booking Lapangan akan muncul di sini.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            // Tambahkan widget lain di sini untuk fitur user...
          ],
        ),
      ),
    );
  }
}