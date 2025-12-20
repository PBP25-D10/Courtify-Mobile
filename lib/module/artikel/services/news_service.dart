import 'package:courtify_mobile/module/artikel/models/news.dart';
import 'package:courtify_mobile/services/auth_service.dart';

class NewsApiService {
  final String baseUrl = "${AuthService.baseHost}/artikel/api";

  Future<List<News>> fetchNews(AuthService auth) async {
    final response = await auth.get("$baseUrl/json/", requireAuth: false);
    final List data = response is List ? response : [];
    return data.map((e) => News.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<News>> fetchMyNews(AuthService auth) async {
    final res = await auth.get("$baseUrl/flutter/my/");
    if (res is Map && res['status'] == 'success') {
      final List data = res['news'] ?? [];
      return data.map((e) => News.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception(res is Map && res['message'] != null ? res['message'] : 'Gagal memuat artikel saya');
  }

  Future<News> createNews(AuthService auth, Map<String, dynamic> payload) async {
    final res = await auth.postJson("$baseUrl/flutter/create/", payload);
    if (res is Map && res['status'] == 'success') {
      final newsData = Map<String, dynamic>.from(res['news'] ?? {});
      return News.fromJson(newsData);
    }
    throw Exception(res['message'] ?? 'Gagal membuat artikel');
  }

  Future<News> updateNews(AuthService auth, int id, Map<String, dynamic> payload) async {
    final res = await auth.postJson("$baseUrl/flutter/update/$id/", payload);
    if (res is Map && res['status'] == 'success') {
      final newsData = Map<String, dynamic>.from(res['news'] ?? {});
      return News.fromJson(newsData);
    }
    throw Exception(res['message'] ?? 'Gagal memperbarui artikel');
  }

  Future<void> deleteNews(AuthService auth, int id) async {
    final res = await auth.postJson("$baseUrl/flutter/delete/$id/", {});
    if (res is Map && res['status'] == 'success') return;
    throw Exception(res['message'] ?? 'Gagal menghapus artikel');
  }
}
