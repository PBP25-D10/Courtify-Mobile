import 'package:flutter/material.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/screens/login_screen.dart';

// Import Menu User
import 'package:courtify_mobile/screens/user/wishlist_user.dart';

// Import Menu Penyedia
import 'package:courtify_mobile/screens/penyedia/dashboard_penyedia.dart';
import 'package:courtify_mobile/screens/penyedia/booking_penyedia.dart';
import 'package:courtify_mobile/screens/penyedia/lapangan_penyedia.dart';
import 'package:courtify_mobile/screens/penyedia/iklan_penyedia.dart';
import 'package:courtify_mobile/screens/penyedia/artikel_penyedia.dart';

import 'package:courtify_mobile/module/booking/screens/booking_dashboard_screen.dart';
import 'package:courtify_mobile/module/artikel/screens/news_list_page.dart';

class RightDrawer extends StatefulWidget {
  const RightDrawer({super.key});

  @override
  State<RightDrawer> createState() => _RightDrawerState();
}

class _RightDrawerState extends State<RightDrawer> {
  final AuthService _authService = AuthService();
  String _username = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? name = await _authService.getCurrentUsername();
    String? role = await _authService.getCurrentRole();
    if (mounted) {
      setState(() {
        _username = name ?? 'Guest';
        _role = role ?? '';
      });
    }
  }

  void _handleLogout() async {
    // Tutup drawer terlebih dahulu
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await _authService.logout();

    if (!mounted) return;
    // Tutup dialog loading
    Navigator.of(context).pop();

    // Kembali ke Login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna header berdasarkan role
    final Color headerColor = _role == 'penyedia'
        ? Colors.teal
        : Colors.blueAccent;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // === HEADER ===
          UserAccountsDrawerHeader(
            accountName: Text(
              _username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              _role == 'penyedia'
                  ? "Role: Penyedia Lapangan"
                  : "Role: Pengguna Biasa",
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                _role == 'penyedia' ? Icons.store : Icons.person,
                size: 40,
                color: headerColor,
              ),
            ),
            decoration: BoxDecoration(color: headerColor),
          ),

          // === MENU ITEMS BERDASARKAN ROLE ===

          // Opsi 1: Jika Role USER
          if (_role == 'user') ...[
            _buildListTile(
              icon: Icons.favorite_border,
              title: "Wishlist",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WishlistUserScreen(),
                ),
              ),
            ),
            _buildListTile(
              icon: Icons.calendar_today,
              title: "Booking Saya",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingDashboardScreen(),
                ),
              ),
            ),
            _buildListTile(
              icon: Icons.article_outlined,
              title: "Artikel",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsListPage()),
              ),
            ),
          ],

          // Opsi 2: Jika Role PENYEDIA
          if (_role == 'penyedia') ...[
            _buildListTile(
              icon: Icons.dashboard,
              title: "Dashboard",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardPenyediaScreen(),
                ),
              ),
            ),
            _buildListTile(
              icon: Icons.book_online,
              title: "Booking Masuk",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingPenyediaScreen(),
                ),
              ),
            ),
            _buildListTile(
              icon: Icons.stadium,
              title: "Kelola Lapangan",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LapanganPenyediaScreen(),
                ),
              ),
            ),
            _buildListTile(
              icon: Icons.campaign,
              title: "Iklan & Promosi",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IklanPenyediaScreen(),
                ),
              ),
            ),
            _buildListTile(
              icon: Icons.article,
              title: "Artikel",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArtikelPenyediaScreen(),
                ),
              ),
            ),
          ],

          const Divider(),

          // === LOGOUT ===
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  // Helper Widget agar kodingan lebih rapi
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Tutup drawer sebelum pindah halaman
        onTap();
      },
    );
  }
}
