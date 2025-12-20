import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/booking/screens/booking_create_screen.dart';
import 'package:courtify_mobile/module/booking/screens/booking_user_list_screen.dart';
import 'package:courtify_mobile/module/booking/services/booking_api_service.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/module/lapangan/services/api_services.dart';

class BookingDashboardScreen extends StatefulWidget {
  const BookingDashboardScreen({super.key});

  @override
  State<BookingDashboardScreen> createState() => _BookingDashboardScreenState();
}

class _BookingDashboardScreenState extends State<BookingDashboardScreen> {
  final BookingApiService _apiService = BookingApiService();
  final LapanganApiService _lapService = LapanganApiService();

  List<Lapangan> _lapangan = [];
  int _currentPage = 1;
  final int _perPage = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  late ScrollController _scrollController;

  static const Color backgroundColor = Color(0xFF111827);
  static const Color cardColor = Color(0xFF1F2937);
  static const Color accent = Color(0xFF2563EB);
  static const Color muted = Colors.white70;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _refreshData();
  }

  void _onScroll() {
    if (!_isLoadingMore &&
        _hasMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMoreLapangan();
    }
  }

  void _refreshData() {
    final request = context.read<AuthService>();
    setState(() {
      _lapangan = [];
      _currentPage = 1;
      _hasMore = true;
    });
    _loadLapanganPage();
  }

  Future<void> _loadLapanganPage() async {
    if (!_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final page = _currentPage;
      final fetched = await _lapService.getPublicLapangan(
        page: page,
        limit: _perPage,
      );
      setState(() {
        _lapangan.addAll(fetched);
        if (fetched.length < _perPage) _hasMore = false;
        _currentPage++;
      });
    } catch (e) {
      // ignore errors for incremental load, show nothing
      _hasMore = false;
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _loadMoreLapangan() {
    if (!_isLoadingMore && _hasMore) {
      _loadLapanganPage();
    }
  }

  String _formatCurrency(num price) {
    return "Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  Future<void> _handleCancelBooking(int bookingId) async {
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
          _refreshData();
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

  void _openAllBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BookingUserListScreen()),
    ).then((_) => _refreshData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Dashboard Booking",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _openAllBookings,
            icon: const Icon(Icons.list_alt),
            tooltip: 'Lihat semua booking',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, const Color(0xFF1a2332)],
            stops: const [0.0, 1.0],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                "Lapangan Tersedia",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              if (_lapangan.isEmpty && !_isLoadingMore)
                _buildEmptyState("Belum ada lapangan tersedia.")
              else
                ..._lapangan.map((lap) => _buildLapanganCard(lap)),

              if (_isLoadingMore)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAllBookings,
        label: const Text("Booking Saya"),
        icon: const Icon(Icons.calendar_month),
        backgroundColor: accent,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildLapanganCard(Lapangan lap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardColor, const Color(0xFF2d3f52)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[900],
            child: lap.fotoUrl != null
                ? Image.network(
                    lap.fotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        const Icon(Icons.broken_image, color: Colors.grey),
                  )
                : const Center(
                    child: Text(
                      "Tidak ada foto",
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        lap.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.favorite_border, color: Colors.white24),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${lap.kategori} - ${lap.lokasi}",
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  "${_formatCurrency(lap.hargaPerJam)} / jam",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.greenAccent,
                  ),
                ),
                Text(
                  "Jam buka ${lap.jamBuka} - ${lap.jamTutup}",
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingCreateScreen(lapangan: lap),
                        ),
                      ).then((result) {
                        if (result == true) {
                          _refreshData();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Pesan Sekarang",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
