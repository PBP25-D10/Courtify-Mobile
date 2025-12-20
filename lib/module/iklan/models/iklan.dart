import 'dart:convert';
import 'package:courtify_mobile/services/auth_service.dart';

List<Iklan> iklanFromJson(String str) {
  final jsonData = json.decode(str);
  
  if (jsonData is Map<String, dynamic> && jsonData.containsKey('iklan_list')) {
    return List<Iklan>.from(jsonData['iklan_list'].map((x) => Iklan.fromJson(x)));
  } else {
    return []; 
  }
}

String iklanToJson(List<Iklan> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Iklan {
  String pk;
  String judul;
  String deskripsi;
  String banner; 
  DateTime tanggal;
  String lapanganId;
  String lapanganNama;

  Iklan({
    required this.pk,
    required this.judul,
    required this.deskripsi,
    required this.banner,
    required this.tanggal,
    required this.lapanganId,
    required this.lapanganNama,
  });

  factory Iklan.fromJson(Map<String, dynamic> json) {
    const fallback =
        "https://images.pexels.com/photos/17724042/pexels-photo-17724042.jpeg";

    String _abs(String? url) {
      if (url == null || url.isEmpty) return "";
      return url.startsWith("http") ? url : "${AuthService.baseHost}$url";
    }

    final candidates = [
      _abs(json["url_thumbnail"]?.toString()),
      _abs(json["banner"]?.toString()),
      _abs(json["lapangan_foto"]?.toString()),
    ];

    final resolved = candidates.firstWhere(
      (u) => u.isNotEmpty,
      orElse: () => fallback,
    );

    return Iklan(
      pk: json["pk"].toString(),
      judul: json["judul"] ?? "Tanpa Judul",
      deskripsi: json["deskripsi"] ?? "",
      banner: resolved,
      tanggal: DateTime.parse(json["tanggal"]),
      lapanganId: json["lapangan_id"].toString(),
      lapanganNama: json["lapangan_nama"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "pk": pk,
    "judul": judul,
    "deskripsi": deskripsi,
    "banner": banner,
    "tanggal": "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}",
    "lapangan_id": lapanganId,
    "lapangan_nama": lapanganNama,
  };
}
