import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/iklan/models/iklan.dart';

class IklanApiService {
  final String baseUrl = "https://justin-timothy-courtify.pbp.cs.ui.ac.id";

  // 1. Fetch Semua Iklan
  Future<List<Iklan>> fetchIklan(AuthService request) async {
    try {
      final response = await request.get("$baseUrl/iklan/show-json/");

      // Cek tipe data response
      if (response is List) {
        return response.map((e) => Iklan.fromJson(e)).toList();
      } else if (response is Map && response['error'] != null) {
        throw Exception(response['error']);
      } else {
        // Jika response bukan List dan bukan Map error, mungkin HTML
        throw Exception("Data yang diterima bukan list iklan. Cek URL server.");
      }
    } catch (e) {
      // Tangkap error spesifik jika URL salah (404)
      if (e.toString().contains("404")) {
         throw Exception("Endpoint tidak ditemukan (404). Pastikan server sudah di-pull/restart.");
      }
      rethrow;
    }
  }

  // 2. Tambah Iklan Baru
  Future<Map<String, dynamic>> createIklan(
    AuthService request,
    Map<String, dynamic> payload,
  ) async {
    // KITA MENGGUNAKAN postForm
    // AuthService baru kamu tidak punya postJson.
    // Pastikan di Django view kamu menggunakan `request.POST.get('key')` 
    // BUKAN `json.loads(request.body)`.
    
    final response = await request.postForm(
      "$baseUrl/iklan/tambah/",
      payload, 
    );

    // Cek status keberhasilan
    if (response['status'] == 'success' || response['status'] == true) {
      return Map<String, dynamic>.from(response);
    } else {
      throw Exception(response['message'] ?? "Gagal membuat iklan baru");
    }
  }

  // 3. Edit Iklan
  Future<Map<String, dynamic>> updateIklan(
    AuthService request,
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await request.postForm(
      "$baseUrl/iklan/edit/$id/",
      payload,
    );

    if (response['status'] == 'success' || response['status'] == true) {
      return Map<String, dynamic>.from(response);
    } else {
      throw Exception(response['message'] ?? "Gagal memperbarui iklan");
    }
  }

  // 4. Hapus Iklan
  Future<bool> deleteIklan(AuthService request, int id) async {
    // Mengirim body kosong {} karena method delete biasanya hanya butuh ID di URL
    final response = await request.postForm(
      "$baseUrl/iklan/hapus/$id/",
      {}, 
    );

    if (response['status'] == 'success' || response['status'] == true) {
      return true;
    } else {
      throw Exception(response['message'] ?? "Gagal menghapus iklan");
    }
  }
}