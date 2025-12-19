class Article {
  final int id;
  final String title;
  final String content;
  final String kategori;
  final String? thumbnail;
  final String createdAt;
  final String author;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.kategori,
    this.thumbnail,
    required this.createdAt,
    required this.author,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
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
