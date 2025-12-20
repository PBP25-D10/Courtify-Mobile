import 'package:courtify_mobile/module/wishlist/models/wishlist_item.dart';
import 'package:courtify_mobile/services/auth_service.dart';

class WishlistApiService {
  final String baseUrl = "${AuthService.baseHost}/wishlist/api";

  Future<List<WishlistItem>> fetchWishlist(AuthService request) async {
    final res = await request.get("$baseUrl/list/");
    if (res is Map && res['status'] == 'success') {
      final List data = res['wishlist'] ?? [];
      return data
          .map((e) => WishlistItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception("Gagal memuat wishlist: $res");
  }

  Future<bool> toggle(AuthService request, String lapanganId) async {
    final res = await request.postJson("$baseUrl/toggle/$lapanganId/", {});
    if (res is Map && res['status'] == 'success') {
      return res['added'] == true;
    }
    throw Exception(res is Map && res['message'] != null
        ? res['message']
        : 'Gagal mengubah wishlist');
  }

  Future<void> deleteById(AuthService request, int wishlistId) async {
    final res = await request.postJson("$baseUrl/delete/$wishlistId/", {});
    if (res is Map && res['status'] == 'success') return;
    throw Exception(res is Map && res['message'] != null
        ? res['message']
        : 'Gagal menghapus wishlist');
  }

  Future<bool> check(AuthService request, String lapanganId) async {
    final res = await request.get("$baseUrl/check/$lapanganId/");
    if (res is Map && res['status'] == 'success') {
      return res['in_wishlist'] == true;
    }
    throw Exception("Gagal mengecek wishlist: $res");
  }
}
