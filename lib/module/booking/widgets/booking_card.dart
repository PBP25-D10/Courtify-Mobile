import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final Function(int) onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
  });

  static const Color cardColor = Color(0xFF1F2937);
  static const Color muted = Colors.white70;

  String _formatCurrency(num price) {
    return "Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
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
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
                const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
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
                    onTap: () => onCancel(booking.id),
                    borderRadius: BorderRadius.circular(4),
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
}
