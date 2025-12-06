import 'dart:convert';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class LapanganApiService {
  final String baseUrl = "https://justin-timothy-courtify.pbp.cs.ui.ac.id";

  Future<List<Lapangan>> getPenyediaLapangan(AuthService request) async {
    try {
      final response = await request.get("$baseUrl/manajemen/api/list/");
      
      if (response is Map && response['status'] == 'success') {
        final List data = response['lapangan_list'];
        return data.map((e) => Lapangan.fromJson(e)).toList();
      } else if (response is List) {
        // Handle if response is directly a list
        return response.map((e) => Lapangan.fromJson(e)).toList();
      } else {
        throw Exception(response['message'] ?? "Failed to fetch data");
      }
    } catch (e) {
      throw Exception("Error fetching lapangan: $e");
    }
  }

  Future<Map<String, dynamic>> createLapangan(
    AuthService request,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await request.postJson(
        "$baseUrl/manajemen/api/create/",
        jsonEncode(payload),
      );
      
      return response;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error creating lapangan: $e'
      };
    }
  }

  Future<Map<String, dynamic>> updateLapangan(
    AuthService request,
    String lapanganId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await request.postJson(
        "$baseUrl/manajemen/api/update/$lapanganId/",
        jsonEncode(payload),
      );
      
      return response;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error updating lapangan: $e'
      };
    }
  }

  Future<Map<String, dynamic>> deleteLapangan(
    AuthService request,
    String lapanganId,
  ) async {
    try {
      final response = await request.post(
        "$baseUrl/manajemen/api/delete/$lapanganId/",
        {},
      );
      
      return response;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error deleting lapangan: $e'
      };
    }
  }
}