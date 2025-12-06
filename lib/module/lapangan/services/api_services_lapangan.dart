import 'dart:convert';
import 'package:flutter/foundation.dart'; // PENTING: Untuk mendeteksi Web
import 'package:http/http.dart' as http;
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class LapanganApiService {
  // LOGIKA DINAMIS:
  // Jika Web -> pakai 127.0.0.1
  // Jika Android Emulator -> pakai 10.0.2.2
  String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    } else {
      return "http://10.0.2.2:8000"; 
    }
  }

  // ===========================
  // READ (GET) LAPANGAN
  // ===========================
  Future<List<Lapangan>> getPenyediaLapangan(int penyediaId) async {
    // Gunakan getter baseUrl di sini
    final url = Uri.parse("$baseUrl/manajemen/api/penyedia/$penyediaId/");
    
    print("Fetching URL: $url"); 

    try {
      final response = await http.get(url);
      
      print("Response Code: ${response.statusCode}");
      // print("Response Body: ${response.body}"); 

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        if (decodedData is List) {
          return decodedData.map((e) => Lapangan.fromJson(e)).toList();
        } 
        else if (decodedData is Map && decodedData.containsKey('lapangan_list')) {
          final List listData = decodedData['lapangan_list'];
          return listData.map((e) => Lapangan.fromJson(e)).toList();
        }
        return [];
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error Fetching: $e");
      rethrow;
    }
  }

  // ===========================
  // CREATE LAPANGAN
  // ===========================
  Future<Map<String, dynamic>> createLapangan(Map<String, dynamic> payload) async {
    final url = Uri.parse("$baseUrl/manajemen/api/create/");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      return jsonDecode(res.body);
    } catch (e) {
      print("Error Create: $e");
      rethrow;
    }
  }

  // ===========================
  // UPDATE LAPANGAN
  // ===========================
  Future<Map<String, dynamic>> updateLapangan(String lapanganId, Map<String, dynamic> payload) async {
    final url = Uri.parse("$baseUrl/manajemen/api/update/$lapanganId/");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      return jsonDecode(res.body);
    } catch (e) {
      print("Error Update: $e");
      rethrow;
    }
  }

  // ===========================
  // DELETE LAPANGAN
  // ===========================
  Future<Map<String, dynamic>> deleteLapangan(String lapanganId) async {
    final url = Uri.parse("$baseUrl/manajemen/api/delete/$lapanganId/");

    try {
      final res = await http.post(url);
      return jsonDecode(res.body);
    } catch (e) {
      print("Error Delete: $e");
      rethrow;
    }
  }
}