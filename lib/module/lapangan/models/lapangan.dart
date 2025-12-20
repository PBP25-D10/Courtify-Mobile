import 'package:courtify_mobile/services/auth_service.dart';

class Lapangan {
  final String idLapangan;
  final String nama;
  final String deskripsi;
  final String kategori;
  final String lokasi;
  final int hargaPerJam;
  final String fotoUrl; // full url with default fallback
  final String jamBuka;  // "HH:mm"
  final String jamTutup; // "HH:mm"

  Lapangan({
    required this.idLapangan,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.lokasi,
    required this.hargaPerJam,
    required this.fotoUrl,
    required this.jamBuka,
    required this.jamTutup,
  });

  static String _normTime(dynamic v) {
    final s = (v ?? "").toString();
    return s.length >= 5 ? s.substring(0, 5) : s; // "07:00:00" -> "07:00"
  }

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    const fallbackFoto =
        'https://images.pexels.com/photos/17724042/pexels-photo-17724042.jpeg';
    final id = (json['id_lapangan'] ?? json['id']).toString();

    String _abs(String? path) {
      if (path == null || path.isEmpty) return '';
      return path.startsWith('http') ? path : "${AuthService.baseHost}$path";
    }

    final fotoUrl = () {
      final candidates = [
        _abs(json['url_thumbnail']?.toString()),
        _abs(json['foto']?.toString()),
      ];
      return candidates.firstWhere((v) => v.isNotEmpty, orElse: () => fallbackFoto);
    }();

    return Lapangan(
      idLapangan: id,
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      lokasi: json['lokasi']?.toString() ?? '',
      hargaPerJam: json['harga_per_jam'] is int
          ? json['harga_per_jam']
          : int.parse(json['harga_per_jam'].toString()),
      fotoUrl: fotoUrl,
      jamBuka: _normTime(json['jam_buka']),
      jamTutup: _normTime(json['jam_tutup']),
    );
  }
}
