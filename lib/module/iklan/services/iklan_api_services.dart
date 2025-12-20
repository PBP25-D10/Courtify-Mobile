import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/iklan/models/iklan.dart';

class IklanApiService {
  final String baseUrl = "https://justin-timothy-courtify.pbp.cs.ui.ac.id";

  Future<List<Iklan>> fetchIklan(AuthService request) async {
    final response = await request.get("$baseUrl/api/iklan/list/");
    
    if (response is Map && response['status'] == 'success') {
      final List data = response['iklan_list'] ?? [];
      return data.map((e) => Iklan.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception("Failed to fetch iklan: $response");
  }

  Future<List<Iklan>> fetchTop10Iklan(AuthService request) async {
    final response = await request.get("$baseUrl/api/iklan/landing/");

    if (response is Map && response['status'] == 'success') {
      final List data = response['iklan_list'] ?? [];
      return data.map((e) => Iklan.fromJson(Map<String, dynamic>.from(e))).toList();
    } 
    throw Exception("Failed to fetch top 10 iklan: $response");
  }

  Future<Map<String, dynamic>> createIklan(AuthService request, Map<String, dynamic> payload) async {
    final res = await request.postForm("$baseUrl/api/iklan/create/", payload);
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> updateIklan(AuthService request, String id, Map<String, dynamic> payload) async {
    final res = await request.postForm("$baseUrl/api/iklan/edit/$id/", payload);
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> deleteIklan(AuthService request, String id) async {
    final res = await request.postForm("$baseUrl/api/iklan/delete/$id/", {});
    return Map<String, dynamic>.from(res);
  }
}