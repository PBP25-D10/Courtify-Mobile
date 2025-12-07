import 'dart:convert';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/iklan/models/iklan.dart';

class IklanApiService {
  final String baseUrl = "https://justin-timothy-courtify.pbp.cs.ui.ac.id";

  // GET: Fetch semua iklan
  Future<List<Iklan>> fetchIklan(AuthService request) async {
    try {
      final response = await request.get("$baseUrl/iklan/show-json/");

      if (response is List) {
        return response.map((e) => Iklan.fromJson(e)).toList();
      } else if (response is Map && response['error'] != null) {
        throw Exception(response['error']);
      } else {
        throw Exception("Format data tidak valid");
      }
    } catch (e) {
      throw Exception("Error fetching iklan: $e");
    }
  }

  // POST: Tambah Iklan Baru
  Future<Map<String, dynamic>> createIklan(
    AuthService request,
    Map<String, dynamic> payload, // Berisi judul, deskripsi, dll
  ) async {
    try {

      final response = await request.post(
        "$baseUrl/iklan/tambah/",
        jsonEncode(payload),
      );

      return response;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error creating iklan: $e',
      };
    }
  }

  // POST: Edit Iklan
  Future<Map<String, dynamic>> updateIklan(
    AuthService request,
    int id, // ID iklan integer
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await request.post(
        "$baseUrl/iklan/edit/$id/",
        jsonEncode(payload),
      );

      return response;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error updating iklan: $e',
      };
    }
  }

  // POST: Hapus Iklan
  Future<Map<String, dynamic>> deleteIklan(
    AuthService request,
    int id,
  ) async {
    try {
      final response = await request.post(
        "$baseUrl/iklan/hapus/$id/",
        {}, // Body kosong
      );

      return response;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error deleting iklan: $e',
      };
    }
  }
}