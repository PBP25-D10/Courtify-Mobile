import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/booking/services/api_services_booking.dart'; // Sesuaikan path
import 'package:courtify_mobile/module/booking/models/booking.dart'; // Sesuaikan path

class BookingUserScreen extends StatefulWidget {
  // Kita butuh cookies dari hasil Login sebelumnya
  final Map<String, String> cookies;

  const BookingUserScreen({
    super.key,
    required this.cookies,
  });

  @override
  State<BookingUserScreen> createState() => _BookingUserScreenState();
}

class _BookingUserScreenState extends State<BookingUserScreen> {
  final BookingApiService _api = BookingApiService();
  late Future<List<Booking>> _futureBookings;

  @override
  void initState() {
    super.initState();
    // Panggil API dengan mengirimkan Cookies yang didapat dari Constructor
    _futureBookings = _api.getUserBookings(widget.cookies);
  }

  // Fungsi untuk refresh (misal ditarik ke bawah)
  Future<void> _refreshData() async {
    setState(() {
      _futureBookings = _api.getUserBookings(widget.cookies);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827), // Dark Theme Background
      appBar: AppBar(
        title: const Text("Booking Saya", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // RefreshIndicator agar user bisa swipe-down untuk reload
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<Booking>>(
          future: _futureBookings,
          builder: (context, snapshot) {
            // 1. LOADING STATE
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. ERROR STATE
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "Terjadi Kesalahan:\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text("Coba Lagi"),
                    )
                  ],
                ),
              );
            }

            final data = snapshot.data;

            // 3. EMPTY STATE
            if (data == null || data.isEmpty) {
              return _emptyState();
            }

            // 4. SUCCESS LIST STATE
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final b = data[index];
                return _buildBookingCard(b);
              },
            );
          },
        ),
      ),
    );
  }

  // -----------------------------
  // WIDGET: EMPTY STATE
  // -----------------------------
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text(
            "Belum ada riwayat booking",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // WIDGET: CARD ITEM
  // -----------------------------
  Widget _buildBookingCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937), // Card Color
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Nama Lapangan & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  b.lapanganNama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(b.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),

          // Detail Info
          _rowDetail(Icons.calendar_today, "Tanggal", b.tanggal),
          const SizedBox(height: 6),
          _rowDetail(Icons.access_time, "Jam", "${b.jamMulai}:00 - ${b.jamSelesai}:00"),
          const SizedBox(height: 6),
          _rowDetail(Icons.attach_money, "Total", "Rp ${b.totalHarga.toStringAsFixed(0)}", 
              valueColor: Colors.blueAccent),
        ],
      ),
    );
  }

  // Helper untuk baris detail icon + text
  Widget _rowDetail(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Helper untuk Badge Status warna-warni
  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'confirmed':
        bg = Colors.green.withOpacity(0.2);
        text = Colors.greenAccent;
        break;
      case 'pending':
        bg = Colors.orange.withOpacity(0.2);
        text = Colors.orangeAccent;
        break;
      case 'cancelled':
        bg = Colors.red.withOpacity(0.2);
        text = Colors.redAccent;
        break;
      default:
        bg = Colors.grey.withOpacity(0.2);
        text = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: text.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}