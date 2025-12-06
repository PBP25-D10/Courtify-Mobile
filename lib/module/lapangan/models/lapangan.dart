class Lapangan {
  final String idLapangan;
  final String nama;
  final String deskripsi;
  final String kategori;
  final String lokasi;
  final int hargaPerJam;
  final String? fotoUrl;
  final String jamBuka;
  final String jamTutup;

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

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    return Lapangan(
      idLapangan: json['id_lapangan'].toString(),
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      kategori: json['kategori'],
      lokasi: json['lokasi'],
      hargaPerJam: json['harga_per_jam'] is int 
          ? json['harga_per_jam'] 
          : int.parse(json['harga_per_jam'].toString()),
      fotoUrl: json['foto'] != null
          ? "https://justin-timothy-courtify.pbp.cs.ui.ac.id${json['foto']}"
          : null,
      jamBuka: json['jam_buka'],
      jamTutup: json['jam_tutup'],
    );
  }
}