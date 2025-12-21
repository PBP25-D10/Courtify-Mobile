import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/booking/services/booking_api_service.dart';
import 'package:courtify_mobile/module/booking/widgets/booking_card.dart';
import 'package:courtify_mobile/theme/app_colors.dart';

class BookingUserListScreen extends StatefulWidget {
  const BookingUserListScreen({super.key});

  @override
  State<BookingUserListScreen> createState() => _BookingUserListScreenState();
}

class _BookingUserListScreenState extends State<BookingUserListScreen> {
  final BookingApiService _apiService = BookingApiService();
  late Future<List<Booking>> _futureBookings;
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';

  static const Color backgroundColor = AppColors.background;
  static const Color cardColor = AppColors.card;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              itemCount: _filtered(bookings).length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _filterPanel();
                final booking = _filtered(bookings)[index - 1];
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

  List<Booking> _filtered(List<Booking> data) {
    final q = _searchController.text.toLowerCase();
    return data.where((b) {
      final matchesSearch =
          q.isEmpty || (b.lapangan?.nama.toLowerCase().contains(q) ?? false);
      final matchesStatus = _statusFilter == 'all' || b.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Widget _filterPanel() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Cari berdasarkan nama lapangan",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.input,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border.withOpacity(0.6)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      dropdownColor: AppColors.input,
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Semua')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _statusFilter = v);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _statusFilter = 'all');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.reset,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Reset"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
