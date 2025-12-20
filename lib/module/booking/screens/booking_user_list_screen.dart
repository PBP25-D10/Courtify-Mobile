import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/booking/services/booking_api_service.dart';
import 'package:courtify_mobile/module/booking/widgets/booking_card.dart';

class BookingUserListScreen extends StatefulWidget {
  const BookingUserListScreen({super.key});

  @override
  State<BookingUserListScreen> createState() => _BookingUserListScreenState();
}

class _BookingUserListScreenState extends State<BookingUserListScreen> {
  final BookingApiService _apiService = BookingApiService();
  late Future<List<Booking>> _futureBookings;

  static const Color backgroundColor = Color(0xFF111827);
  static const Color cardColor = Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final request = context.read<AuthService>();
    setState(() {
      _futureBookings = _apiService.getUserBookings(request);
    });
  }

  Future<void> _handleCancelBooking(int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text("Batalkan Booking", style: TextStyle(color: Colors.white)),
        content: const Text("Yakin ingin membatalkan booking ini?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.redAccent)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Riwayat Booking",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Booking>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

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
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loadBookings,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada riwayat booking.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final bookings = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _loadBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
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
