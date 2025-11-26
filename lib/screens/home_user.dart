// lib/screens/home_user.dart

import 'package:flutter/material.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/screens/login_screen.dart';
// --- IMPORT HALAMAN MENU USER ---
import 'package:courtify_mobile/screens/user/wishlist_user.dart';
import 'package:courtify_mobile/screens/user/booking_user.dart';
import 'package:courtify_mobile/screens/user/artikel_user.dart';
import 'package:courtify_mobile/widgets/right_drawer.dart';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  final AuthService _authService = AuthService();
  String _username = 'Loading...';

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

  // Fungsi Logout (Tetap dipertahankan di AppBar, opsional bisa dipindah ke drawer)
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
        title: const Text("Courtify"), // Judul dipersingkat
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        // Tombol logout tetap di kanan atas
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      // === MENAMBAHKAN DRAWER (MENU SAMPING) ===
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header Drawer dengan info user
            UserAccountsDrawerHeader(
              accountName: Text(
                _username,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: const Text("Role: Pengguna Biasa"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 24.0, color: Colors.blueAccent),
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            // Menu Item 1: Wishlist
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Wishlist'),
              onTap: () {
                // Tutup drawer dulu
                Navigator.pop(context);
                // Navigasi ke halaman Wishlist
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistUserScreen()),
                );
              },
            ),
             // Menu Item 2: Booking
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Booking Saya'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingUserScreen()),
                );
              },
            ),
             // Menu Item 3: Artikel
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Artikel'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ArtikelUserScreen()),
                );
              },
            ),
            const Divider(),
            // Opsional: Tambahkan tombol logout di drawer juga
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                _handleLogout(); // Panggil fungsi logout
              },
            ),
          ],
        ),
      ),
      endDrawer: const RightDrawer(),
      // === BODY HALAMAN UTAMA ===
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu sapaan sederhana di home screen
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Selamat datang kembali, $_username!",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Gunakan menu di samping (pojok kiri atas) untuk navigasi.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}