//import 'package:courtify_mobile/env/env.dart'; // kalau pakai env
import 'package:courtify_mobile/module/artikel/models/article.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ArticleService {
  final String baseUrl = "http://localhost:8000";  // untuk Chrome

  Future<List<Article>> fetchArticles(CookieRequest request) async {
    final response = await request.get("$baseUrl/artikel/json/");

    List<Article> list = [];
    for (var d in response) {
      list.add(Article.fromJson(d));
    }
    return list;
  }
}
