import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/lapangan/services/api_services.dart';

class BookingApiService {
  final String baseUrl = "${AuthService.baseHost}/booking/api";

  Future<Map<String, dynamic>> getDashboardData(AuthService request) async {
    final bookings = await getUserBookings(request);
    final lapanganList = await LapanganApiService().getPublicLapangan();
    return {'bookings': bookings, 'lapangan_list': lapanganList};
  }

  Future<List<Booking>> getUserBookings(AuthService request) async {
    final response = await request.get("$baseUrl/flutter/bookings/");
    if (response is Map && response['success'] == true) {
      final List data = response['bookings'] ?? [];
      return data
          .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception("Gagal memuat booking user");
  }

  Future<Booking?> createBooking(
    AuthService request,
    String idLapangan,
    Map<String, dynamic> data,
  ) async {
    final response = await request.postJson(
      "$baseUrl/flutter/bookings/create/$idLapangan/",
      data,
    );

    if (response is Map && response['success'] == true) {
      if (response['booking'] != null) {
        return Booking.fromJson(Map<String, dynamic>.from(response['booking']));
      }
      return null;
    }
    throw Exception(response['message'] ?? 'Gagal membuat booking');
  }

  Future<List<Booking>> getOwnerBookings(AuthService request, {String? status}) async {
    final query = (status != null && status.isNotEmpty && status != 'all')
        ? "?status=$status"
        : "";
    final response = await request.get("$baseUrl/flutter/bookings/owner/$query");
    if (response is Map && response['success'] == true) {
      final List data = response['bookings'] ?? [];
      return data
          .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception(response['message'] ?? 'Gagal memuat booking penyedia');
  }

  Future<bool> cancelBooking(AuthService request, int bookingId) async {
    final response = await request.postJson(
      "$baseUrl/flutter/bookings/cancel/$bookingId/",
      {},
    );

    if (response is Map && response['success'] == true) return true;
    throw Exception(response['message'] ?? 'Gagal membatalkan booking');
  }

  Future<bool> confirmBooking(AuthService request, int bookingId) async {
    final response = await request.postJson(
      "$baseUrl/flutter/bookings/confirm/$bookingId/",
      {},
    );
    if (response is Map && response['success'] == true) return true;
    throw Exception(response['message'] ?? 'Gagal konfirmasi booking');
  }

  Future<bool> ownerCancelBooking(AuthService request, int bookingId) async {
    final response = await request.postJson(
      "$baseUrl/flutter/bookings/owner/cancel/$bookingId/",
      {},
    );

    if (response is Map && response['success'] == true) return true;
    throw Exception(response['message'] ?? 'Gagal membatalkan booking');
  }

  Future<List<int>> getBookedHours(
    AuthService request,
    String idLapangan,
    String tanggal,
  ) async {
    final response = await request.get(
      "$baseUrl/flutter/booked/$idLapangan/$tanggal/",
    );

    if (response is Map && response['success'] == true) {
      return response['jam_terpakai'] != null
          ? List<int>.from(response['jam_terpakai'])
          : [];
    }
    throw Exception(response['message'] ?? "Gagal mengambil jam terpakai");
  }
}
