import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final Function(int) onCancel; // Callback function saat tombol batal ditekan

  const BookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
  });

  // Helper format currency
  String _formatCurrency(num price) {
    return "Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    String statusText;

    // Logika warna status
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
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), 
            blurRadius: 5, 
            offset: const Offset(0, 2)
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris 1: Nama Lapangan & Status Badge
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
                    style: TextStyle(
                      color: statusColor, 
                      fontSize: 11, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Baris 2: Tanggal & Jam
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${booking.tanggal} | ${booking.jamMulai} - ${booking.jamSelesai}", 
                  style: const TextStyle(fontSize: 13, color: Colors.black54)
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Baris 3: Harga & Tombol Batal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatCurrency(booking.totalHarga),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 15, 
                    color: Colors.black87
                  ),
                ),
                // Tombol Cancel hanya muncul jika status bukan cancelled
                if (booking.status != 'cancelled')
                  InkWell(
                    onTap: () => onCancel(booking.id),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        "Batalkan", 
                        style: TextStyle(
                          color: Colors.red, 
                          fontWeight: FontWeight.w600, 
                          fontSize: 13
                        )
                      ),
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
}