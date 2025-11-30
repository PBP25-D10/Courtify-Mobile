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
      idLapangan: json['id_lapangan'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      kategori: json['kategori'],
      lokasi: json['lokasi'],
      hargaPerJam: json['harga_per_jam'],
      fotoUrl: json['foto'] != null
          ? "http://10.0.2.2:8000${json['foto']}"
          : null,
      jamBuka: json['jam_buka'],
      jamTutup: json['jam_tutup'],
    );
  }
}
