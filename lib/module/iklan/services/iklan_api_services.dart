import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/iklan/models/iklan.dart';

class IklanApiService {
  final String baseUrl = "https://justin-timothy-courtify.pbp.cs.ui.ac.id";

  // Fetch Semua Iklan user
  Future<List<Iklan>> fetchIklan(AuthService request) async {
    try {
      final response = await request.get("$baseUrl/iklan/show-json/");

      if (response is List) {
        return response.map((e) => Iklan.fromJson(e)).toList();
      } else if (response is Map && response['error'] != null) {
        throw Exception(response['error']);
      } else {
        throw Exception("Data yang diterima bukan list iklan.");
      }
    } catch (e) {
      if (e.toString().contains("404")) {
         throw Exception("Endpoint tidak ditemukan (404).");
      }
      rethrow;
    }
  }

  // Fetch 10 iklan terbaru untuk landing page
  Future<List<Iklan>> fetchTop10Iklan(AuthService request) async {
    try {
        final response = await request.get("$baseUrl/iklan/show-top10/"); 

        if (response is List) {
           return response.map((e) => Iklan.fromJson(e)).toList();
        } else {
           throw Exception('Respon bukan list data');
        }
    } catch (e) {
        throw Exception('Gagal memuat iklan terbaru: $e');
    }
  }

  // Tambah Iklan Baru
  Future<Map<String, dynamic>> createIklan(
    AuthService request,
    Map<String, dynamic> payload,
  ) async {
    final response = await request.postForm(
      "$baseUrl/iklan/tambah/",
      payload, 
    );

    if (response['success'] == true) {
      return Map<String, dynamic>.from(response);
    } else {
      throw Exception(response['message'] ?? "Gagal membuat iklan baru");
    }
  }

  // Edit Iklan
  Future<Map<String, dynamic>> updateIklan(
    AuthService request,
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await request.postForm(
      "$baseUrl/iklan/edit/$id/",
      payload,
    );

    if (response['success'] == true) {
      return Map<String, dynamic>.from(response);
    } else {
      throw Exception(response['message'] ?? "Gagal memperbarui iklan");
    }
  }

  // Hapus Iklan
  Future<bool> deleteIklan(AuthService request, int id) async {
    final response = await request.postForm(
      "$baseUrl/iklan/hapus/$id/",
      {}, 
    );

    if (response['success'] == true) {
      return true;
    } else {
      throw Exception(response['message'] ?? "Gagal menghapus iklan");
    }
  }
}