import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class Booking {
  final int id;
  final Lapangan? lapangan; // Menggunakan model Lapangan yang sudah ada
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
      id: json['id'],
      // Handle jika lapangan null atau objek
      lapangan: json['lapangan'] != null 
          ? Lapangan.fromJson(json['lapangan']) // Pastikan Lapangan.fromJson kamu support format ini
          : null,
      tanggal: json['tanggal'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      totalHarga: (json['total_harga'] as num).toDouble(),
      status: json['status'],
    );
  }
}