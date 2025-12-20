import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/booking/screens/booking_create_screen.dart';
import 'package:courtify_mobile/module/booking/screens/booking_user_list_screen.dart';
import 'package:courtify_mobile/module/booking/services/booking_api_service.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class BookingDashboardScreen extends StatefulWidget {
  const BookingDashboardScreen({super.key});

  @override
  State<BookingDashboardScreen> createState() => _BookingDashboardScreenState();
}

class _BookingDashboardScreenState extends State<BookingDashboardScreen> {
  final BookingApiService _apiService = BookingApiService();
  late Future<Map<String, dynamic>> _futureDashboardData;
  late ScrollController _scrollController;

  List<Lapangan> _displayedLapangan = [];
  List<Lapangan> _allLapangan = [];
  int _itemsPerPage = 4;
  bool _isLoadingMore = false;

  static const Color backgroundColor = Color(0xFF111827);
  static const Color cardColor = Color(0xFF1F2937);
  static const Color accent = Color(0xFF2563EB);
  static const Color muted = Colors.white70;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _refreshData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreLapangan();
    }
  }

  void _loadMoreLapangan() {
    if (!_isLoadingMore && _displayedLapangan.length < _allLapangan.length) {
      setState(() {
        _isLoadingMore = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            int endIndex = (_displayedLapangan.length + _itemsPerPage).clamp(
              0,
              _allLapangan.length,
            );
            _displayedLapangan = _allLapangan.sublist(0, endIndex);
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  void _refreshData() {
    final request = context.read<AuthService>();
    setState(() {
      _displayedLapangan = [];
      _allLapangan = [];
      _futureDashboardData = _apiService.getDashboardData(request).then((data) {
        final lapanganList = data['lapangan_list'] as List<Lapangan>;
        _allLapangan = lapanganList;
        _displayedLapangan = lapanganList.take(_itemsPerPage).toList();
        return data;
      });
    });
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
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
        child: FutureBuilder<Map<String, dynamic>>(
          future: _futureDashboardData,
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
            if (!snapshot.hasData) {
              return const SizedBox();
            }

            final bookings = snapshot.data!['bookings'] as List<Booking>;

            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text(
                    "Booking Terbaru",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (bookings.isEmpty)
                    _buildEmptyState("Belum ada booking yang dibuat.")
                  else
                    ...bookings.map((booking) => _buildBookingCard(booking)),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _openAllBookings,
                      child: const Text(
                        "Lihat semua booking",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 24),

                  const Text(
                    "Lapangan Tersedia",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_displayedLapangan.isEmpty)
                    _buildEmptyState("Belum ada lapangan tersedia.")
                  else
                    ..._displayedLapangan.map((lap) => _buildLapanganCard(lap)),

                  if (_isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[400]!,
                          ),
                        ),
                      ),
                    ),

                  if (_displayedLapangan.length < _allLapangan.length)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          "Scroll untuk memuat lebih banyak (${_displayedLapangan.length}/${_allLapangan.length})",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 60),
                ],
              ),
            );
          },
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

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (booking.status) {
      case 'confirmed':
        statusColor = Colors.greenAccent.shade200;
        statusBgColor = const Color.fromRGBO(0, 128, 0, 0.1);
        statusText = "Dikonfirmasi";
        break;
      case 'cancelled':
        statusColor = Colors.redAccent.shade100;
        statusBgColor = const Color.fromRGBO(244, 67, 54, 0.1);
        statusText = "Dibatalkan";
        break;
      default:
        statusColor = Colors.orangeAccent.shade100;
        statusBgColor = const Color.fromRGBO(255, 152, 0, 0.1);
        statusText = "Menunggu Konfirmasi";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.lapangan?.nama ?? "Lapangan Tidak Dikenal",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  "${booking.tanggal} | ${booking.jamMulai} - ${booking.jamSelesai}",
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatCurrency(booking.totalHarga),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                if (booking.status != 'cancelled')
                  InkWell(
                    onTap: () => _handleCancelBooking(booking.id),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        "Batalkan",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  const Text("-", style: TextStyle(color: Colors.white38)),
              ],
            ),
          ],
        ),
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
    _scrollController.dispose();
    super.dispose();
  }
}
