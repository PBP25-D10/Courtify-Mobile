class News {
  final int id;
  final String title;
  final String content;
  final String kategori;
  final String thumbnail;
  final String author;
  final String createdAt;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.kategori,
    required this.thumbnail,
    required this.author,
    required this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      kategori: (json['kategori'] ?? '') as String,
      thumbnail: (json['thumbnail'] ?? '') as String,
      createdAt: (json['created_at'] ?? '') as String,
      author: (json['author'] ?? '') as String,
    );
  }
}
