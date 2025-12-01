import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class LapanganApiService {
  final String baseUrl = "http://10.0.2.2:8000";

  Future<List<Lapangan>> getPenyediaLapangan(int penyediaId) async {
    final url = Uri.parse("$baseUrl/lapangan/api/penyedia/$penyediaId/");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Lapangan.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data lapangan penyedia");
    }
  }
  Future<Map<String, dynamic>> createLapangan(
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse("$baseUrl/lapangan/api/create/");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> updateLapangan(
    String lapanganId,
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse("$baseUrl/lapangan/api/update/$lapanganId/");

    final res = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    return jsonDecode(res.body);
  }

  // ===========================
  // DELETE LAPANGAN
  // ===========================
  Future<Map<String, dynamic>> deleteLapangan(String lapanganId) async {
    final url = Uri.parse("$baseUrl/lapangan/api/delete/$lapanganId/");

    final res = await http.delete(url);

    return jsonDecode(res.body);
  }
}