import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/booking/services/booking_api_service.dart';
import 'package:courtify_mobile/module/booking/widgets/booking_card.dart'; // Import widget yang baru dibuat

class BookingUserListScreen extends StatefulWidget {
  const BookingUserListScreen({super.key});

  @override
  State<BookingUserListScreen> createState() => _BookingUserListScreenState();
}

class _BookingUserListScreenState extends State<BookingUserListScreen> {
  final BookingApiService _apiService = BookingApiService();
  late Future<List<Booking>> _futureBookings;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // Fungsi untuk memuat data booking
  void _loadBookings() {
    final request = context.read<AuthService>();
    setState(() {
      _futureBookings = _apiService.getUserBookings(request);
    });
  }

  // Fungsi Cancel Booking (Sama logicnya dengan Dashboard)
  Future<void> _handleCancelBooking(int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Booking"),
        content: const Text("Yakin ingin membatalkan booking ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(color: Colors.red),
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
          _loadBookings(); // Refresh list setelah cancel berhasil
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Background abu muda
      appBar: AppBar(
        title: const Text(
          "Riwayat Booking",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder<List<Booking>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Error: ${snapshot.error}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loadBookings,
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada riwayat booking.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final bookings = snapshot.data!;

          // 4. Success State (List Data)
          return RefreshIndicator(
            onRefresh: () async => _loadBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                // Menggunakan Widget BookingCard yang kita buat di nomor 1
                return BookingCard(
                  booking: booking,
                  onCancel: _handleCancelBooking,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
