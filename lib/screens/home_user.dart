// lib/screens/home_user.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/screens/login_screen.dart';
import 'package:courtify_mobile/screens/user/wishlist_user.dart';
import 'package:courtify_mobile/screens/user/artikel_user.dart';
import 'package:courtify_mobile/module/booking/screens/booking_dashboard_screen.dart';
import 'package:courtify_mobile/module/booking/services/booking_api_service.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/booking/widgets/booking_card.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/module/iklan/models/iklan.dart';
import 'package:courtify_mobile/module/iklan/services/iklan_api_services.dart';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  final AuthService _authService = AuthService();
  final BookingApiService _apiService = BookingApiService();
  final IklanApiService _iklanApiService = IklanApiService();
  String _username = 'Loading...';
  int _selectedIndex = 0;
  late PageController _pageController;
  TextEditingController _searchController = TextEditingController();
  late PageController _iklanPageController;

  static const Color backgroundColor = Color(0xFF111827);
  static const Color cardColor = Color(0xFF1F2937);
  static const Color accent = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _iklanPageController = PageController(viewportFraction: 0.88);
    _loadUserData();
    _loadLapangan();
    _loadBookings();
  }

  void _loadBookings() {
    setState(() {
      // _futureBookings is managed in _buildHomePage
    });
  }

  Future<void> _handleCancelBookingHome(int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text(
          "Batalkan Booking",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Yakin ingin membatalkan booking ini?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final request = context.read<AuthService>();
      try {
        final success = await _apiService.cancelBooking(request, bookingId);
        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Booking berhasil dibatalkan"),
              backgroundColor: Colors.green,
            ),
          );
          _loadBookings();
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal membatalkan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    String? name = await _authService.getCurrentUsername();
    setState(() {
      _username = name ?? 'User';
    });
  }

  void _loadLapangan() {
    // Not needed for current implementation
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

  String _formatCurrency(num price) {
    return "Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, const Color(0xFF1a2332)],
            stops: const [0.0, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                        "Yakin ingin keluar dari akun?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleLogout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Logout"),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              // Home/Browse Courts
              _buildHomePage(),
              // Booking
              const BookingDashboardScreen(),
              // Articles
              const ArtikelUserScreen(),
              // Wishlist
              const WishlistUserScreen(),
            ],
          ),
          bottomNavigationBar: SizedBox(
            height: 72,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background bar
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
                          Icons.home,
                          Icons.calendar_today,
                          Icons.article,
                          Icons.favorite,
                        ];
                        final labels = [
                          "Home",
                          "Booking",
                          "Artikel",
                          "Wishlist",
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

  Widget _buildLapanganGridCard(Lapangan lap) {
    return GestureDetector(
      onTap: () {
        // Navigate to booking create screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BookingDashboardScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardColor, const Color(0xFF2d3f52)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey[900],
              child: lap.fotoUrl != null
                  ? Image.network(
                      lap.fotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) =>
                          const Icon(Icons.broken_image, color: Colors.grey),
                    )
                  : const Center(child: Icon(Icons.image, color: Colors.grey)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lap.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                lap.lokasi,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      _formatCurrency(lap.hargaPerJam),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
    _iklanPageController.dispose();
  }

  Widget _buildHomePage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF111827),
              const Color(0xFF1a2f4f),
            const Color(0xFF0F1624),
            const Color(0xFF1a3a5a),
            const Color(0xFF1F2937),
            const Color(0xFF2a1f3f),
          ],
          stops: const [0.0, 0.25, 0.5, 0.65, 0.85, 1.0],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Booking Terbaru',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: () => _loadBookings(),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Booking>>(
              future: _apiService.getUserBookings(context.read<AuthService>()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada riwayat booking',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadBookings(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = items[index];
                      return BookingCard(
                        booking: b,
                        onCancel: (id) => _handleCancelBookingHome(id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildIklanSection(),
        ],
      ),
    );
  }

  Widget _buildIklanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            children: const [
              Icon(Icons.campaign, color: Colors.orangeAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Iklan Menarik',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 210,
          child: FutureBuilder<List<Iklan>>(
            future: _iklanApiService.fetchTop10Iklan(context.read<AuthService>()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Gagal memuat iklan: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada iklan',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return PageView.builder(
                controller: _iklanPageController,
                itemCount: items.length,
                padEnds: false,
                itemBuilder: (context, index) {
                  final iklan = items[index];
                  return AnimatedBuilder(
                    animation: _iklanPageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_iklanPageController.position.hasContentDimensions) {
                        value = (_iklanPageController.page ?? 0) - index;
                        value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                      }
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: _iklanCard(iklan),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _iklanCard(Iklan iklan) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        iklan.judul,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "${iklan.tanggal.day.toString().padLeft(2, '0')}/${iklan.tanggal.month.toString().padLeft(2, '0')}",
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  iklan.deskripsi,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Tutup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                iklan.banner,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white54),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      iklan.judul,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      iklan.deskripsi,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
