import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class LapanganApiService {
  final String baseUrl = "https://justin-timothy-courtify.pbp.cs.ui.ac.id";

  Future<List<Lapangan>> getPenyediaLapangan(AuthService request) async {
    final response = await request.get("$baseUrl/manajemen/api/list/");
    if (response is Map && response['status'] == 'success') {
      final List data = response['lapangan_list'] ?? [];
      return data.map((e) => Lapangan.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception("Failed to fetch lapangan: $response");
  }

  Future<Map<String, dynamic>> createLapangan(AuthService request, Map<String, dynamic> payload) async {
    final res = await request.postForm("$baseUrl/manajemen/api/create/", payload);
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> updateLapangan(AuthService request, String lapanganId, Map<String, dynamic> payload) async {
    final res = await request.postForm("$baseUrl/manajemen/api/update/$lapanganId/", payload);
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> deleteLapangan(AuthService request, String lapanganId) async {
    final res = await request.postForm("$baseUrl/manajemen/api/delete/$lapanganId/", {});
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> uploadFotoLapangan(
    AuthService request, {
    required String lapanganId,
    required File imageFile,
  }) async {
    final uri = Uri.parse("$baseUrl/manajemen/api/upload-foto/$lapanganId/");
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
