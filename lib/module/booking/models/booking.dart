import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class Booking {
  final int id;
  final Lapangan? lapangan;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final double totalHarga;
  final String status;

  Booking({
    required this.id,
    this.lapangan,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.totalHarga,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,

      lapangan: json['lapangan'] != null
          ? Lapangan.fromJson(Map<String, dynamic>.from(json['lapangan']))
          : null,

      tanggal: json['tanggal']?.toString() ?? '',
      jamMulai: json['jam_mulai']?.toString() ?? '',
      jamSelesai: json['jam_selesai']?.toString() ?? '',
      totalHarga: (json['total_harga'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
    );
  }
}
