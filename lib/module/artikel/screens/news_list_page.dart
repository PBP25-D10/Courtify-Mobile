import 'package:courtify_mobile/module/artikel/services/news_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/news.dart';
import '../services/news_service.dart';
import '../../../services/auth_service.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final NewsApiService service = NewsApiService();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text("Berita Olahraga")),
      body: FutureBuilder<List<News>>(
        future: service.fetchNews(auth),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada berita"));
          }

          final newsList = snapshot.data!;

          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: news.thumbnail.isNotEmpty
                      ? Image.network(
                          news.thumbnail,
                          width: 80,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(news.title),
                  subtitle: Text(news.kategori),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await service.deleteNews(auth, news.id);
                      setState(() {}); // refresh list
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailPage(news: news),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final News news;

  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(news.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (news.thumbnail.isNotEmpty) Image.network(news.thumbnail),
            const SizedBox(height: 10),
            Text(
              news.kategori,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(news.content),
          ],
        ),
      ),
    );
  }
}
