// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import '../models/news.dart';

// class NewsService {
//   final String baseUrl = "http://localhost:8000"; // chrome

//   Future<List<News>> fetchNews(CookieRequest request) async {
//     final response = await request.get("$baseUrl/artikel/json/");

//     final List<News> list = [];
//     for (final d in response) {
//       list.add(News.fromJson(Map<String, dynamic>.from(d)));
//     }
//     return list;
//   }
// }


import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/artikel/models/news.dart';

class NewsApiService {
  // SAMAKAN dengan BookingApiService
  final String baseUrl = "https://justin-timothy-courtify.pbp.cs.ui.ac.id";

  // 1️⃣ Ambil semua berita (LIST)
  Future<List<News>> fetchNews(AuthService request) async {
    final response = await request.get("$baseUrl/artikel/json/");

    // response di sini SUDAH berupa decoded JSON (List / Map)
    final List data = response;

    return data
        .map((e) => News.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // 2️⃣ Tambah berita (OWNER)
  Future<bool> createNews(
    AuthService request,
    Map<String, dynamic> data,
  ) async {
    final response = await request.postJson(
      "$baseUrl/artikel/create-flutter/",
      data,
    );

    return response['status'] == 'success';
  }

  // 3️⃣ Hapus berita (OWNER)
  Future<bool> deleteNews(AuthService request, int idBerita) async {
    final response = await request.postJson(
      "$baseUrl/artikel/delete-flutter/$idBerita/",
      {},
    );

    return response['status'] == 'success';
  }
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/news.dart';

// class NewsService {
//   final String baseUrl = "http://localhost:8000";

//   Future<List<News>> fetchNews() async {
//     final response = await http.get(Uri.parse("$baseUrl/artikel/json/"));
//     final data = jsonDecode(response.body) as List;
//     return data.map((e) => News.fromJson(e)).toList();
//   }

//   Future<void> deleteNews(int id) async {
//     await http.post(Uri.parse("$baseUrl/artikel/delete-flutter/$id/"));
//   }
// }