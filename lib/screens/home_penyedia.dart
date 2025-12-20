import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';

import 'package:courtify_mobile/screens/login_screen.dart';

// --- IMPORT HALAMAN MENU PENYEDIA ---
import 'package:courtify_mobile/screens/penyedia/dashboard_penyedia.dart';
import 'package:courtify_mobile/screens/penyedia/lapangan_penyedia.dart';
import 'package:courtify_mobile/screens/penyedia/iklan_penyedia.dart';
import 'package:courtify_mobile/screens/penyedia/artikel_penyedia.dart';

class HomePenyediaScreen extends StatefulWidget {
  const HomePenyediaScreen({super.key});

  @override
  State<HomePenyediaScreen> createState() => _HomePenyediaScreenState();
}

class _HomePenyediaScreenState extends State<HomePenyediaScreen> {
  static const Color backgroundColor = Color(0xFF111827);
  static const Color cardColor = Color(0xFF1F2937);
  static const Color accent = Color(0xFF2563EB);

  String _username = "Loading...";
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadUserData();
  }

  void _loadUserData() async {
    final request = context.read<AuthService>();

    // Username otomatis dari Django

    final data = await request.getJsonData();

    setState(() {
      _username = data["username"] ?? "Penyedia";
    });
  }

  Future<void> _handleLogout() async {
    final request = context.read<AuthService>();

    final nav = Navigator.of(context, rootNavigator: true);

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: const [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          "Anda yakin ingin keluar?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await request.logout();
    if (!mounted) return;

    nav.pop(); // close loading
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _onNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF111827),
              Color(0xFF1a2f4f),
              Color(0xFF0F1624),
              Color(0xFF1a3a5a),
              Color(0xFF1F2937),
              Color(0xFF2a1f3f),
            ],
            stops: [0.0, 0.25, 0.5, 0.65, 0.85, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hello,",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                Text(
                  _username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              IklanPenyediaScreen(),
              DashboardPenyediaScreen(),
              LapanganPenyediaScreen(),
              ArtikelPenyediaScreen(),
            ],
          ),
          bottomNavigationBar: SizedBox(
            height: 72,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(4, (index) {
                        final icons = [
                          Icons.campaign,
                          Icons.dashboard,
                          Icons.stadium,
                          Icons.article,
                        ];
                        final labels = [
                          "Iklan",
                          "Dashboard",
                          "Lapangan",
                          "Artikel",
                        ];
                        final isSelected = _selectedIndex == index;
                        return GestureDetector(
                          onTap: () => _onNavItemTapped(index),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icons[index],
                                size: 22,
                                color: isSelected ? accent : Colors.white54,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                labels[index],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected ? accent : Colors.white54,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
