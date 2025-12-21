import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/booking/services/booking_api_service.dart';
import 'package:courtify_mobile/theme/app_colors.dart';

class DashboardPenyediaScreen extends StatefulWidget {
  const DashboardPenyediaScreen({super.key});

  static const Color backgroundColor = AppColors.background;
  static const Color cardColor = AppColors.card;
  static const Color accent = AppColors.primary;
  static const Color muted = Colors.white70;

  @override
  State<DashboardPenyediaScreen> createState() => _DashboardPenyediaScreenState();
}

class _DashboardPenyediaScreenState extends State<DashboardPenyediaScreen> {
  final BookingApiService _bookingApi = BookingApiService();
  late Future<List<Booking>> _futureOwnerBookings;
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadOwnerBookings();
  }

  void _loadOwnerBookings() {
    final auth = context.read<AuthService>();
    setState(() {
      _futureOwnerBookings = _bookingApi.getOwnerBookings(
        auth,
        status: _statusFilter == 'all' ? null : _statusFilter,
      );
    });
  }

  Future<void> _handleConfirm(int bookingId) async {
    final auth = context.read<AuthService>();
    try {
      await _bookingApi.confirmBooking(auth, bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking dikonfirmasi")),
      );
      _loadOwnerBookings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal konfirmasi: $e")),
      );
    }
  }

  Future<void> _handleReject(int bookingId) async {
    final auth = context.read<AuthService>();
    try {
      await _bookingApi.ownerCancelBooking(auth, bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking dibatalkan")),
      );
      _loadOwnerBookings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membatalkan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardPenyediaScreen.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Dashboard Booking Penyedia",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: DashboardPenyediaScreen.backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Booking>>(
        future: _futureOwnerBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildMessageCard(
              "Error memuat booking: ${snapshot.error}",
              action: ElevatedButton(
                onPressed: _loadOwnerBookings,
                child: const Text("Coba Lagi"),
              ),
            );
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return _buildMessageCard("Belum ada booking untuk lapangan Anda.");
          }

          return RefreshIndicator(
            onRefresh: () async => _loadOwnerBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _statusFilterRow();
                }
                final booking = bookings[index - 1];
                return _bookingCard(booking);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _statusFilterRow() {
    const items = [
      DropdownMenuItem(value: 'all', child: Text('Semua')),
      DropdownMenuItem(value: 'pending', child: Text('Pending')),
      DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
    ];
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                  items: items,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _statusFilter = v);
                    _loadOwnerBookings();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String message, {Widget? action}) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DashboardPenyediaScreen.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              action,
            ],
          ],
        ),
      ),
    );
  }

  Widget _bookingCard(Booking booking) {
    final statusColor = () {
      switch (booking.status) {
        case 'confirmed':
          return Colors.greenAccent;
        case 'cancelled':
          return Colors.redAccent;
        default:
          return Colors.orangeAccent;
      }
    }();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardPenyediaScreen.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.lapangan?.nama ?? "Lapangan",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${booking.tanggal} • ${booking.jamMulai} - ${booking.jamSelesai}",
            style: const TextStyle(color: DashboardPenyediaScreen.muted),
          ),
          if (booking.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              "Dibuat: ${booking.createdAt}",
              style: const TextStyle(color: DashboardPenyediaScreen.muted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (booking.status == 'pending') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleConfirm(booking.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade400,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleReject(booking.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Text(
                    booking.status == 'confirmed'
                        ? "Booking sudah dikonfirmasi."
                        : "Booking dibatalkan.",
                    style: const TextStyle(color: DashboardPenyediaScreen.muted),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
