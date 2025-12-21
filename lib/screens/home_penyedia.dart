import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';

import 'package:courtify_mobile/screens/landing_screen.dart';

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                useRootNavigator: true,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              try {
                await request.logout();
              } catch (e) {
                // ignore error, continue clearing session & navigation
              } finally {
                if (!mounted) return;
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LandingScreen()),
                  (route) => false,
                );
              }
            },
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final navBottomPadding = bottomInset > 0 ? bottomInset + 8 : 16.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        color: backgroundColor,
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
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, navBottomPadding),
              child: Material(
                elevation: 12,
                shadowColor: Colors.black.withOpacity(0.35),
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              size: 24,
                              color: isSelected ? accent : Colors.white54,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              labels[index],
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? accent : Colors.white54,
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
