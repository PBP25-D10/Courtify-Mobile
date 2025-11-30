import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';

class BookingApiService {
  final String baseUrl = "http://127.0.0.1:8000";

  // ===========================
  // GET LIST LAPANGAN
  // ===========================
  Future<List<Lapangan>> getLapanganList() async {
    final url = Uri.parse("$baseUrl/booking/api/lapangan/");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Lapangan.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data lapangan");
    }
  }

  // ===========================
  // CREATE BOOKING
  // ===========================
  Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse("$baseUrl/booking/api/create/");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    return jsonDecode(res.body);
  }

  // ===========================
  // GET USER BOOKINGS
  // ===========================
  Future<List<Booking>> getUserBookings(int userId) async {
    final url = Uri.parse("$baseUrl/booking/api/user/$userId/");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Booking.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil booking user");
    }
  }
}
