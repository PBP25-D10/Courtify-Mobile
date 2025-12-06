import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';

class BookingApiService {
  // ⚠️ Ganti sesuai device:
  // Android Emulator: "http://10.0.2.2:8000"
  // HP Fisik/Laptop: "http://192.168.x.x:8000"
  final String baseUrl = "http://10.0.2.2:8000"; 

  // Helper untuk membuat header
  Map<String, String> _getHeaders(Map<String, String> cookies) {
    return {
      "Content-Type": "application/json",
      "X-Requested-With": "XMLHttpRequest", // Wajib agar Django return JSON
      ...cookies, // Gabungkan cookie login
    };
  }

  // ===========================
  // 1. GET LIST LAPANGAN
  // ===========================
  Future<List<Lapangan>> getLapanganList(Map<String, String> cookies) async {
    final url = Uri.parse("$baseUrl/booking/api/lapangan/");
    
    try {
      final response = await http.get(url, headers: _getHeaders(cookies));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List data = jsonResponse['lapangan_list'] ?? []; 
        return data.map((e) => Lapangan.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Sesi habis. Silakan login kembali.");
      } else {
        throw Exception("Gagal memuat data (Status: ${response.statusCode})");
      }
    } catch (e) {
      rethrow;
    }
  }

  // ===========================
  // 2. CREATE BOOKING
  // ===========================
  Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> payload,
    Map<String, String> cookies,
  ) async {
    final url = Uri.parse("$baseUrl/booking/api/create/");

    try {
      final res = await http.post(
        url,
        headers: _getHeaders(cookies),
        body: jsonEncode(payload),
      );
      
      // Decode response apapun status codenya untuk melihat pesan error dari Django
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Gagal membuat booking: $e");
    }
  }

  // ===========================
  // 3. GET USER BOOKINGS
  // ===========================
  Future<List<Booking>> getUserBookings(Map<String, String> cookies) async {
    // Pastikan URL ini benar di Django urls.py
    final url = Uri.parse("$baseUrl/booking/api/user/list/"); 

    final response = await http.get(url, headers: _getHeaders(cookies));

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      
      List data = [];
      if (decodedData is Map<String, dynamic>) {
          data = decodedData['booking_list'] ?? []; 
      } else if (decodedData is List) {
          data = decodedData;
      }
      return data.map((e) => Booking.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data booking user");
    }
  }
}