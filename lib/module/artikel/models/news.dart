class News {
  final int id;
  final String title;
  final String content;
  final String kategori;
  final String thumbnailUrl;
  final String author;
  final String createdAt;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.kategori,
    required this.thumbnailUrl,
    required this.author,
    required this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    const fallbackThumb =
        'https://images.pexels.com/photos/17724042/pexels-photo-17724042.jpeg';
    return News(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      kategori: (json['kategori'] ?? '') as String,
      thumbnailUrl: (json['url_thumbnail'] ??
              json['thumbnail_url'] ??
              json['thumbnail'] ??
              fallbackThumb) as String,
      createdAt: (json['created_at'] ?? '') as String,
      author: (json['author'] ?? '') as String,
    );
  }
}
