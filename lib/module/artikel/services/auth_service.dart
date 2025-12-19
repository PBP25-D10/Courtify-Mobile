
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://justin-timothy-courtify.pbp.cs.ui.ac.id';
  static const String _loginUrl = '$_baseUrl/auth/api/flutter/login/';
  static const String _registerUrl = '$_baseUrl/auth/api/flutter/register/';
  static const String _logoutUrl = '$_baseUrl/auth/api/flutter/logout/';

  static const String _keyCookies = 'all_cookies';
  static const String _keyRole = 'user_role';
  static const String _keyUsername = 'user_username';

  Future<void> _saveToLocal(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> _getFromLocal(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        // ✅ cookie parse aman (tanpa split koma)
        final String? setCookieHeader = response.headers['set-cookie'];
        if (setCookieHeader == null || setCookieHeader.isEmpty) {
          return {'status': false, 'message': 'Login berhasil tapi Set-Cookie tidak ada.'};
        }

        final Map<String, String> cookies = {};
        final reg = RegExp(r'(^|,)\s*([^=;\s]+)=([^;]+)');
        for (final m in reg.allMatches(setCookieHeader)) {
          final name = m.group(2)!;
          final value = m.group(3)!;
          final lower = name.toLowerCase();

          if (lower == 'expires' ||
              lower == 'max-age' ||
              lower == 'path' ||
              lower == 'domain' ||
              lower == 'samesite' ||
              lower == 'secure' ||
              lower == 'httponly') {
            continue;
          }
          cookies[name] = value;
        }

        await _saveToLocal(_keyCookies, jsonEncode(cookies));
        await _saveToLocal(_keyRole, responseData['role']?.toString() ?? '');
        await _saveToLocal(_keyUsername, responseData['username']?.toString() ?? '');
      }

      return Map<String, dynamic>.from(responseData);
    } catch (e) {
      return {'status': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse(_registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password, 'role': role}),
      );
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      return {'status': false, 'message': 'Error register: $e'};
    }
  }

  Future<void> logout() async {
    final cookiesHeader = await getCookiesHeader();
    try {
      if (cookiesHeader.isNotEmpty) {
        await http.post(
          Uri.parse(_logoutUrl),
          headers: {'Content-Type': 'application/json', 'Cookie': cookiesHeader},
        );
      }
    } catch (_) {
      // ignore server logout error
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final cookiesJson = await _getFromLocal(_keyCookies);
    if (cookiesJson == null || cookiesJson.isEmpty) return false;
    try {
      final Map<String, dynamic> cookies = jsonDecode(cookiesJson);
      return cookies.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getCurrentRole() async => _getFromLocal(_keyRole);
  Future<String?> getCurrentUsername() async => _getFromLocal(_keyUsername);

  Future<Map<String, dynamic>> getJsonData() async {
    final username = await _getFromLocal(_keyUsername);
    final role = await _getFromLocal(_keyRole);
    return {'username': username, 'role': role};
  }

  // ✅ dipakai untuk multipart upload foto
  Future<String> getCookiesHeader() async {
    final cookiesJson = await _getFromLocal(_keyCookies);
    if (cookiesJson == null || cookiesJson.isEmpty) return "";
    final Map<String, dynamic> cookies = jsonDecode(cookiesJson);
    if (cookies.isEmpty) return "";
    return cookies.entries.map((e) => "${e.key}=${e.value}").join("; ");
  }

  Future<dynamic> get(String url) async {
    final cookiesHeader = await getCookiesHeader();
    if (cookiesHeader.isEmpty) throw Exception('No cookies found. User not logged in.');

    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': cookiesHeader, 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }
    throw Exception('GET request failed: ${response.statusCode} - ${response.body}');
  }

  // ✅ untuk Django request.POST (form-urlencoded)
  Future<dynamic> postForm(String url, Map<String, dynamic> data) async {
    final cookiesHeader = await getCookiesHeader();
    if (cookiesHeader.isEmpty) throw Exception('No cookies found. User not logged in.');

    final body = data.map((k, v) => MapEntry(k, v == null ? '' : v.toString()));

    final response = await http.post(
      Uri.parse(url),
      headers: {'Cookie': cookiesHeader, 'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      if (response.statusCode == 204 || response.body.isEmpty) return {};
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }
    throw Exception('POST FORM request failed: ${response.statusCode} - ${response.body}');
  }
}
