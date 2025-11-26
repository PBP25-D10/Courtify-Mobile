// lib/screens/home_penyedia.dart

import 'package:flutter/material.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/screens/login_screen.dart';
// --- IMPORT HALAMAN MENU PENYEDIA ---
import 'package:courtify_mobile/screens/penyedia/dashboard_penyedia.dart';
import 'package:courtify_mobile/screens/penyedia/booking_penyedia.dart';
import 'package:courtify_mobile/screens/penyedia/lapangan_penyedia.dart';
import 'package:courtify_mobile/screens/penyedia/iklan_penyedia.dart';
import 'package:courtify_mobile/screens/penyedia/artikel_penyedia.dart';
import 'package:courtify_mobile/widgets/right_drawer.dart';
////
class HomePenyediaScreen extends StatefulWidget {
  const HomePenyediaScreen({super.key});

  @override
  State<HomePenyediaScreen> createState() => _HomePenyediaScreenState();
}

class _HomePenyediaScreenState extends State<HomePenyediaScreen> {
  final AuthService _authService = AuthService();
  String _username = 'Loading...';

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
        title: const Text("Courtify Owner"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      // === MENAMBAHKAN DRAWER KHUSUS PENYEDIA ===
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _username,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: const Text("Role: Penyedia Lapangan"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.store, size: 40, color: Colors.teal),
              ),
              decoration: const BoxDecoration(
                color: Colors.teal,
              ),
            ),
            // Menu Item 1: Dashboard
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardPenyediaScreen()),
                );
              },
            ),
            // Menu Item 2: Booking
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('Booking Masuk'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingPenyediaScreen()),
                );
              },
            ),
            // Menu Item 3: Lapangan
            ListTile(
              leading: const Icon(Icons.stadium),
              title: const Text('Kelola Lapangan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LapanganPenyediaScreen()),
                );
              },
            ),
             // Menu Item 4: Iklan
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Iklan & Promosi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IklanPenyediaScreen()),
                );
              },
            ),
             // Menu Item 5: Artikel
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Artikel'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ArtikelPenyediaScreen()),
                );
              },
            ),
             const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _handleLogout();
              },
            ),
          ],
        ),
      ),
      endDrawer: const RightDrawer(),
      // === BODY HALAMAN UTAMA ===
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store_mall_directory, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              Text(
                "Halo, $_username!",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
               const SizedBox(height: 10),
              const Text(
                "Tekan ikon garis tiga di pojok kiri atas untuk mengakses menu pengelolaan.",
                textAlign: TextAlign.center,
                 style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}