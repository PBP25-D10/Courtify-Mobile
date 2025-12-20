import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class LapanganApiService {
  final String baseUrl = "${AuthService.baseHost}/manajemen/api";

  Future<List<Lapangan>> getPenyediaLapangan(AuthService request) async {
    final response = await request.get("$baseUrl/list/");
    if (response is Map && response['status'] == 'success') {
      final List data = response['lapangan_list'] ?? [];
      return data.map((e) => Lapangan.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception("Failed to fetch lapangan: $response");
  }

  Future<List<Lapangan>> getPublicLapangan({
    String? kategori,
    String? lokasi,
    String? hargaMin,
    String? hargaMax,
  }) async {
    final query = <String, String>{};
    if (kategori != null && kategori.isNotEmpty) query['kategori'] = kategori;
    if (lokasi != null && lokasi.isNotEmpty) query['lokasi'] = lokasi;
    if (hargaMin != null && hargaMin.isNotEmpty) query['harga_min'] = hargaMin;
    if (hargaMax != null && hargaMax.isNotEmpty) query['harga_max'] = hargaMax;

    final uri = Uri.parse("$baseUrl/public/").replace(queryParameters: query.isEmpty ? null : query);
    final res = await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (res.statusCode == 200) {
      final body = Map<String, dynamic>.from(jsonDecode(res.body));
      final List data = body['lapangan_list'] ?? body['lapangan'] ?? [];
      return data.map((e) => Lapangan.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception("Failed to fetch public lapangan: ${res.statusCode} ${res.body}");
  }

  Future<Lapangan> getLapanganDetail(String idLapangan) async {
    final uri = Uri.parse("$baseUrl/detail/$idLapangan/");
    final res = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      final body = Map<String, dynamic>.from(jsonDecode(res.body));
      final data = Map<String, dynamic>.from(body['lapangan'] ?? {});
      return Lapangan.fromJson(data);
    }
    throw Exception("Failed to fetch detail lapangan: ${res.statusCode}");
  }

  Future<List<Lapangan>> getLapanganByPenyedia(String penyediaId) async {
    final uri = Uri.parse("$baseUrl/penyedia/$penyediaId/");
    final res = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Lapangan.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception("Failed to fetch lapangan by penyedia: ${res.statusCode}");
  }

  Future<Map<String, dynamic>> createLapangan(AuthService request, Map<String, dynamic> payload) async {
    final res = await request.postJson("$baseUrl/create/", payload);
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> updateLapangan(AuthService request, String lapanganId, Map<String, dynamic> payload) async {
    final res = await request.postJson("$baseUrl/update/$lapanganId/", payload);
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> deleteLapangan(AuthService request, String lapanganId) async {
    final res = await request.postJson("$baseUrl/delete/$lapanganId/", {});
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> uploadFotoLapangan(
    AuthService request, {
    required String lapanganId,
    required File imageFile,
  }) async {
    final uri = Uri.parse("$baseUrl/upload-foto/$lapanganId/");
    final cookies = await request.getCookiesHeader();

    final req = http.MultipartRequest("POST", uri);
    if (cookies.isNotEmpty) req.headers['Cookie'] = cookies;

    req.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return {};
      return Map<String, dynamic>.from(jsonDecode(resp.body));
    }
    throw Exception("Upload foto gagal: ${resp.statusCode} - ${resp.body}");
  }
}
