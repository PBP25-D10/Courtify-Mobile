import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/module/booking/services/booking_api_service.dart';
import 'package:courtify_mobile/module/booking/screens/booking_create_screen.dart';

// Ganti import ini sesuai lokasi file form booking/lapangan kamu
import 'package:courtify_mobile/module/lapangan/screens/lapangan_form_screen.dart'; 

// import 'package:courtify_mobile/module/booking/screens/booking_create_screen.dart'; // Buat nanti

class BookingDashboardScreen extends StatefulWidget {
  const BookingDashboardScreen({super.key});

  @override
  State<BookingDashboardScreen> createState() => _BookingDashboardScreenState();
}

class _BookingDashboardScreenState extends State<BookingDashboardScreen> {
  final BookingApiService _apiService = BookingApiService();
  late Future<Map<String, dynamic>> _futureDashboardData;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final request = context.read<AuthService>();
    setState(() {
      _futureDashboardData = _apiService.getBookingDashboard(request);
    });
  }

  // Helper untuk format mata uang sederhana
  String _formatCurrency(double price) {
    return "Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  // Fungsi Batalkan Booking
  Future<void> _handleCancelBooking(int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Booking"),
        content: const Text("Yakin ingin membatalkan booking ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final request = context.read<AuthService>();
      try {
        final success = await _apiService.cancelBooking(request, bookingId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booking berhasil dibatalkan"), backgroundColor: Colors.green),
          );
          _refreshData(); // Refresh tampilan
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membatalkan: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Background abu muda seperti HTML
      appBar: AppBar(
        title: const Text("Dashboard Booking", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureDashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final bookings = snapshot.data!['bookings'] as List<Booking>;
          final lapanganList = snapshot.data!['lapangan_list'] as List<Lapangan>;

          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER SECTION ---
                  const Text(
                    "📅 5 Booking Terbaru",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  // --- BOOKING LIST SECTION ---
                  if (bookings.isEmpty)
                    _buildEmptyState("Belum ada booking yang dibuat.")
                  else
                    ...bookings.map((booking) => _buildBookingCard(booking)),

                  // Link "Lihat Semua"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                         // Navigasi ke List Semua Booking
                         // Navigator.pushNamed(context, '/my-bookings');
                      },
                      child: const Text("Lihat semua booking →"),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // --- LAPANGAN SECTION ---
                  const Text(
                    "🏟️ Lapangan Tersedia",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  if (lapanganList.isEmpty)
                    _buildEmptyState("Belum ada lapangan tersedia.")
                  else
                    ...lapanganList.map((lap) => _buildLapanganCard(lap)),

                   // Link "Lihat Semua Lapangan"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                         // Navigasi ke List Semua Lapangan (Sesuai kode kamu sebelumnya)
                         // Navigator.push(context, MaterialPageRoute(builder: (_) => LapanganListScreen()));
                      },
                      child: const Text("Lihat semua lapangan →"),
                    ),
                  ),
                  
                  const SizedBox(height: 60), // Space untuk FAB
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           // Navigasi ke Form Booking atau List Lapangan untuk booking
           // Navigator.pushNamed(context, '/booking-list');
        },
        label: const Text("Buat Booking"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    Color statusBgColor;
    String statusText;

    // Logic Status warna (mirip HTML)
    switch (booking.status) {
      case 'confirmed':
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green[100]!;
        statusText = "Dikonfirmasi";
        break;
      case 'cancelled':
        statusColor = Colors.red[800]!;
        statusBgColor = Colors.red[100]!;
        statusText = "Dibatalkan";
        break;
      default: // pending
        statusColor = Colors.orange[800]!;
        statusBgColor = Colors.orange[100]!;
        statusText = "Menunggu Konfirmasi";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${booking.tanggal} • ${booking.jamMulai} - ${booking.jamSelesai}", 
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatCurrency(booking.totalHarga),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                ),
                if (booking.status != 'cancelled')
                  InkWell(
                    onTap: () => _handleCancelBooking(booking.id),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text("Batalkan", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  )
                else
                  const Text("-", style: TextStyle(color: Colors.grey)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Lapangan
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[200],
            child: lap.fotoUrl != null
                ? Image.network(
                    // Sesuaikan base URL jika fotoUrl dari API belum absolut
                    // Jika URL sudah full path (https://...), langsung pakai lap.fotoUrl!
                    lap.fotoUrl!.startsWith('http') 
                        ? lap.fotoUrl! 
                        : "https://justin-timothy-courtify.pbp.cs.ui.ac.id${lap.fotoUrl}", 
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                  )
                : const Center(child: Text("Tidak ada foto", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))),
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Tombol Wishlist (Hanya UI, logika backend terpisah)
                    const Icon(Icons.favorite_border, color: Colors.grey), 
                  ],
                ),
                const SizedBox(height: 4),
                Text("${lap.kategori} • ${lap.lokasi}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  "${_formatCurrency(lap.hargaPerJam.toDouble())} / jam",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
                ),
                Text(
                  "⏰ ${lap.jamBuka.toString().substring(0,5)} - ${lap.jamTutup.toString().substring(0,5)}",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 16),
                
                // Tombol Pesan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman create booking
                      // --- UPDATE BAGIAN INI ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingCreateScreen(lapangan: lap),
                        ),
                      ).then((result) {
                        // Jika booking berhasil (result == true), refresh dashboard
                        if (result == true) {
                          _refreshData();
                        }
                      });
                      // -------------------------
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => BookingCreateScreen(lapangan: lap)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Pesan Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}