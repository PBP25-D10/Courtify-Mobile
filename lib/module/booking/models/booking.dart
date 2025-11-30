
class Booking {
  final int id;
  final String lapanganNama;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final double totalHarga;
  final String status;

  Booking({
    required this.id,
    required this.lapanganNama,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.totalHarga,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      lapanganNama: json['lapangan_nama'],
      tanggal: json['tanggal'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      // Handle jika harga datang sebagai String atau Double/Decimal
      totalHarga: double.parse(json['total_harga'].toString()),
      status: json['status'],
    );
  }
}