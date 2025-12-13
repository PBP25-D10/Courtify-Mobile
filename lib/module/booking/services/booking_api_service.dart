import 'dart:convert';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class BookingApiService {
  // Sesuaikan URL ini dengan URL Django kamu
  final String baseUrl = "https://justin-timothy-courtify.pbp.cs.ui.ac.id";

  // 1. Fetch Dashboard Data (5 Booking Terakhir & 5 Lapangan)
  Future<Map<String, dynamic>> getBookingDashboard(AuthService request) async {
    final response = await request.get("$baseUrl/booking/dashboard/");
    
    if (response['status'] == 'success') {
      // Parse Bookings
      final List bookingsData = response['bookings'] ?? [];
      List<Booking> bookings = bookingsData
          .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Parse Lapangan (Recommendation)
      final List lapanganData = response['lapangan_list'] ?? [];
      List<Lapangan> lapanganList = lapanganData
          .map((e) => Lapangan.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return {
        'bookings': bookings,
        'lapangan_list': lapanganList,
      };
    }
    throw Exception("Gagal mengambil data dashboard: ${response['message']}");
  }

  // 2. Fetch Semua Booking User
  Future<List<Booking>> getUserBookings(AuthService request) async {
    final response = await request.get("$baseUrl/booking/my-bookings/");
    
    if (response['status'] == 'success') {
      final List data = response['bookings'] ?? [];
      return data.map((e) => Booking.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception("Gagal mengambil daftar booking.");
  }

  // 3. Create Booking
  Future<Map<String, dynamic>> createBooking(
    AuthService request, 
    String idLapangan, 
    Map<String, dynamic> data
  ) async {
    // data harus berisi: {'tanggal': 'YYYY-MM-DD', 'jam_mulai': 'HH:MM', 'jam_selesai': 'HH:MM'}
    final response = await request.postForm(
      "$baseUrl/booking/create/$idLapangan/", 
      data
    );

    if (response['success'] == true) {
      return response;
    } else {
      throw Exception(response['errors'] ?? "Gagal membuat booking");
    }
  }

  // 4. Cancel Booking
  Future<bool> cancelBooking(AuthService request, int bookingId) async {
    // Menggunakan post karena endpoint Django menggunakan POST untuk cancel
    final response = await request.postForm(
      "$baseUrl/booking/cancel/$bookingId/", 
      {}
    );

    if (response['success'] == true) {
      return true;
    }
    return false;
  }

  // 5. Cek Jam Terpakai (Untuk Form Booking)
  Future<List<int>> getBookedHours(AuthService request, String idLapangan, String tanggal) async {
    final response = await request.get("$baseUrl/booking/api/booked/$idLapangan/$tanggal/");
    
    if (response['jam_terpakai'] != null) {
      return List<int>.from(response['jam_terpakai']);
    }
    return [];
  }
}