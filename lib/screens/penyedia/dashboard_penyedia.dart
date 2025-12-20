import 'package:courtify_mobile/module/iklan/models/iklan.dart';
import 'package:courtify_mobile/module/iklan/services/iklan_api_services.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/booking/services/booking_api_service.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/module/lapangan/services/api_services.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPenyediaScreen extends StatefulWidget {
  const DashboardPenyediaScreen({super.key});

  @override
  State<DashboardPenyediaScreen> createState() =>
      _DashboardPenyediaScreenState();
}

class _DashboardPenyediaScreenState extends State<DashboardPenyediaScreen> {
  static const Color backgroundColor = Color(0xFF111827);
  static const Color cardColor = Color(0xFF1F2937);
  static const Color accent = Color(0xFF2563EB);
  static const Color muted = Colors.white70;

  final LapanganApiService _lapanganApi = LapanganApiService();
  final IklanApiService _iklanApi = IklanApiService();
  final BookingApiService _bookingApi = BookingApiService();
  final Set<int> _confirmingIds = {};

  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_DashboardData> _loadData() async {
    final request = context.read<AuthService>();
    final lapangan = await _lapanganApi.getPenyediaLapangan(request);
    final iklan = await _iklanApi.fetchIklan(request);
    final bookings = await _bookingApi.getOwnerBookings(request, status: "pending");
    return _DashboardData(lapangan: lapangan, iklan: iklan, bookings: bookings);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadData();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Dashboard Statistik",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: accent,
        child: FutureBuilder<_DashboardData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildError(snapshot.error.toString());
            }
            final data = snapshot.data;
            if (data == null) {
              return _buildError("Gagal memuat data.");
            }

            final lapangan = data.lapangan;
            final iklan = data.iklan;
            final bookings = data.bookings;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: "Lapangan Aktif",
                          value: lapangan.length.toString(),
                          icon: Icons.stadium_outlined,
                          color: Colors.greenAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: "Iklan Aktif",
                          value: iklan.length.toString(),
                          icon: Icons.campaign_outlined,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildBookingSection(bookings),
                  const SizedBox(height: 16),
                  _buildListSection(
                    title: "Lapangan Terdaftar",
                    emptyText: "Belum ada lapangan yang dibuat.",
                    items: lapangan
                        .take(5)
                        .map(
                          (l) => _ListItem(
                            title: l.nama,
                            subtitle: l.lokasi,
                            trailing: "Rp${l.hargaPerJam}",
                          ),
                        )
                        .toList(),
                    totalCount: lapangan.length,
                  ),
                  const SizedBox(height: 16),
                  _buildListSection(
                    title: "Iklan Terbaru",
                    emptyText: "Belum ada iklan yang dibuat.",
                    items: iklan
                        .take(5)
                        .map(
                          (i) => _ListItem(
                            title: i.judul,
                            subtitle: i.lapanganNama.isNotEmpty
                                ? i.lapanganNama
                                : "Tanpa Lapangan",
                            trailing:
                                "${i.tanggal.day}/${i.tanggal.month}/${i.tanggal.year}",
                          ),
                        )
                        .toList(),
                    totalCount: iklan.length,
                  ),
                  const SizedBox(height: 20),
                  _buildTipsCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
            const SizedBox(height: 12),
            Text(
              "Gagal memuat dashboard",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required String emptyText,
    required List<_ListItem> items,
    required int totalCount,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  totalCount.toString(),
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              emptyText,
              style: const TextStyle(color: muted),
            )
          else
            ...items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (item.subtitle != null &&
                              item.subtitle!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                item.subtitle!,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (item.trailing != null && item.trailing!.isNotEmpty)
                      Text(
                        item.trailing!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBookingSection(List<Booking> bookings) {
    final items = bookings.take(5).toList();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Booking Masuk",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  bookings.length.toString(),
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text(
              "Belum ada booking pending.",
              style: TextStyle(color: muted),
            )
          else
            ...items.map((b) {
              final jam = "${b.jamMulai} - ${b.jamSelesai}";
              final tgl = b.tanggal;
              final lap = b.lapangan?.nama ?? "Lapangan";
              final harga = b.totalHarga > 0 ? _formatCurrency(b.totalHarga) : "";
              final isPending = b.status == 'pending';
              final isLoading = _confirmingIds.contains(b.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lap,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$tgl | $jam",
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                          if (harga.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                harga,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPending ? Colors.orange.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        b.status,
                        style: TextStyle(
                          color: isPending ? Colors.orangeAccent : Colors.greenAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: isLoading ? null : () => _confirmBooking(b.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.withOpacity(0.12),
                          foregroundColor: Colors.greenAccent,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Terima"),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value == 0) return "";
    return "Rp${value.toStringAsFixed(0)}";
  }

  Future<void> _confirmBooking(int bookingId) async {
    setState(() {
      _confirmingIds.add(bookingId);
    });
    try {
      final request = context.read<AuthService>();
      await _bookingApi.confirmBooking(request, bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking diterima")),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menerima booking: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _confirmingIds.remove(bookingId);
        });
      }
    }
  }

  Widget _buildTipsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.lightbulb_outline, color: accent, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Tips: Pastikan lapangan dan iklan selalu diperbarui supaya pengguna mudah menemukan penawaran Anda.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardData {
  final List<Lapangan> lapangan;
  final List<Iklan> iklan;
  final List<Booking> bookings;

  _DashboardData({
    required this.lapangan,
    required this.iklan,
    required this.bookings,
  });
}

class _ListItem {
  final String title;
  final String? subtitle;
  final String? trailing;

  _ListItem({required this.title, this.subtitle, this.trailing});
}
