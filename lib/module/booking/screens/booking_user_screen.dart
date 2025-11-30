import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/booking/services/api_services.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';

class BookingUserScreen extends StatefulWidget {
  const BookingUserScreen({super.key});

  @override
  State<BookingUserScreen> createState() => _BookingUserScreenState();
}

class _BookingUserScreenState extends State<BookingUserScreen> {
  final BookingApiService _api = BookingApiService();
  late Future<List<Booking>> _futureBookings;

  @override
  void initState() {
    super.initState();

    // ===========================
    // Dummy userId sementara
    // nanti diganti dari login
    // ===========================
    const int userId = 1;

    _futureBookings = _api.getUserBookings(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Booking Saya", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: FutureBuilder<List<Booking>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final data = snapshot.data;

          // KOSONG
          if (data == null || data.isEmpty) {
            return _emptyState();
          }

          // LIST BOOKING
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
    );
  }

  // -----------------------------
  // EMPTY STATE
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
          const SizedBox(height: 8),
          const Text(
            "Jika Anda sudah login, data akan muncul di sini.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // BOOKING CARD
  // -----------------------------
  Widget _buildBookingCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            b.lapanganNama,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Tanggal: ${b.tanggal}",
            style: const TextStyle(color: Colors.grey),
          ),

          Text(
            "Jam: ${b.jamMulai} - ${b.jamSelesai}",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 6),

          Text(
            "Total Harga: Rp ${b.totalHarga.toStringAsFixed(0)}",
            style: const TextStyle(color: Colors.blueAccent),
          ),

          const SizedBox(height: 6),

          Text(
            "Status: ${b.status}",
            style: TextStyle(
              color: b.status == "confirmed"
                  ? Colors.greenAccent
                  : b.status == "pending"
                      ? Colors.yellowAccent
                      : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
