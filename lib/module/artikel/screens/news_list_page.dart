import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/module/artikel/models/news.dart';
import 'package:courtify_mobile/module/artikel/screens/article_form_page.dart';
import 'package:courtify_mobile/module/artikel/services/news_service.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/theme/app_colors.dart';

class NewsListPage extends StatefulWidget {
  final bool isProvider;
  const NewsListPage({super.key, this.isProvider = false});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final NewsApiService service = NewsApiService();
  late Future<List<News>> _futureNews;
  late bool _isProvider;
  final TextEditingController _searchController = TextEditingController();
  String _selectedKategori = 'Semua';

  @override
  void initState() {
    super.initState();
    _isProvider = widget.isProvider;
    _futureNews = _fetchForRole();
    _loadRole();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
    final auth = context.read<AuthService>();
    final role = await auth.getCurrentRole();
    final nextIsProvider = widget.isProvider || role == 'penyedia';
    if (!mounted || nextIsProvider == _isProvider) return;
    setState(() {
      _isProvider = nextIsProvider;
      _futureNews = _fetchForRole();
    });
  }

  Future<List<News>> _fetchForRole() {
    final auth = context.read<AuthService>();
    return _isProvider ? service.fetchMyNews(auth) : service.fetchNews(auth);
  }

  void _loadNews() {
    setState(() {
      _futureNews = _fetchForRole();
    });
  }

  Future<void> _deleteNews(int id) async {
    final auth = context.read<AuthService>();
    try {
      await service.deleteNews(auth, id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Artikel dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadNews();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openForm({News? news}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleFormPage(news: news)),
    );
    if (result == true) {
      _loadNews();
    }
  }

  List<News> _applyFilters(List<News> data) {
    final q = _searchController.text.toLowerCase();
    return data.where((news) {
      final matchesQuery = q.isEmpty ||
          news.title.toLowerCase().contains(q) ||
          news.content.toLowerCase().contains(q) ||
          news.author.toLowerCase().contains(q);
      final matchesKategori =
          _selectedKategori == 'Semua' || news.kategori == _selectedKategori;
      return matchesQuery && matchesKategori;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _isProvider ? 'Kelola Artikel' : 'Artikel Olahraga',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<News>>(
        future: _futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada berita',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final newsList = snapshot.data!;

          final content = _isProvider ? _buildProviderList(newsList) : _buildUserList(newsList);
          return content;
        },
      ),
      floatingActionButton: _isProvider
          ? FloatingActionButton(
              onPressed: () => _openForm(),
              backgroundColor: const Color(0xFF2563EB),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildUserList(List<News> newsList) {
    final filtered = _applyFilters(newsList);
    return RefreshIndicator(
      onRefresh: () async => _loadNews(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _userSearchBar();
          final news = filtered[index - 1];
          return _newsCard(news);
        },
      ),
    );
  }

  Widget _userSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Cari judul artikel",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildProviderList(List<News> newsList) {
    final categories = <String>{'Semua', ...newsList.map((e) => e.kategori)}.toList();
    final filtered = _applyFilters(newsList);

    return RefreshIndicator(
      onRefresh: () async => _loadNews(),
          child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Cari judul, isi, atau penulis",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: categories.contains(_selectedKategori) ? _selectedKategori : 'Semua',
                  dropdownColor: AppColors.input,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Kategori",
                  ),
                  items: categories
                      .map((k) => DropdownMenuItem(value: k, child: Text(k, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedKategori = v ?? 'Semua'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() {}),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Filter", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _selectedKategori = 'Semua';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.reset,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Reset", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'Tidak ada artikel yang cocok dengan filter',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            ...filtered.map((news) => _newsCard(news)),
        ],
      ),
    );
  }

  Widget _newsCard(News news) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewsDetailPage(news: news)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.thumbnailUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  news.thumbnailUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: Colors.grey[900],
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          news.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (_isProvider)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () => _openForm(news: news),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: const Color(0xFF1F2937),
                                    title: const Text(
                                      'Hapus artikel?',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: const Text(
                                      'Tindakan ini tidak dapat dibatalkan.',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          'Hapus',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  _deleteNews(news.id);
                                }
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    news.kategori,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${news.author} ? ${news.createdAt}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(news.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              if (news.thumbnailUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    news.thumbnailUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[900],
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                news.kategori,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                news.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'By ${news.author} ? ${news.createdAt}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                news.content,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
