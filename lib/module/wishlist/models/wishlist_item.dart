import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class WishlistItem {
  final int id;
  final Lapangan lapangan;
  final String createdAt;

  WishlistItem({
    required this.id,
    required this.lapangan,
    required this.createdAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    final lap = Map<String, dynamic>.from(json['lapangan'] ?? {});
    // API memberikan id_lapangan di dalam lapangan
    if (!lap.containsKey('id_lapangan') && lap.containsKey('id')) {
      lap['id_lapangan'] = lap['id'];
    }
    return WishlistItem(
      id: json['id'] as int,
      lapangan: Lapangan.fromJson(lap),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}
