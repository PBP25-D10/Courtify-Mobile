import 'dart:convert';

List<Iklan> iklanFromJson(String str) =>
    List<Iklan>.from(json.decode(str).map((x) => Iklan.fromJson(x)));

String iklanToJson(List<Iklan> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Iklan {
  int pk;
  String judul;
  String deskripsi;
  String? banner;
  DateTime tanggal;

  Iklan({
    required this.pk,
    required this.judul,
    required this.deskripsi,
    this.banner,
    required this.tanggal,
  });

  factory Iklan.fromJson(Map<String, dynamic> json) => Iklan(
    pk: json["pk"],
    judul: json["judul"],
    deskripsi: json["deskripsi"],
    banner: json["banner"],
    tanggal: DateTime.parse(json["tanggal"]),
  );

  Map<String, dynamic> toJson() => {
    "pk": pk,
    "judul": judul,
    "deskripsi": deskripsi,
    "banner": banner,
    "tanggal": tanggal.toIso8601String(),
  };
}
