import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:courtify_mobile/services/http_client_factory_stub.dart'
    if (dart.library.html) 'package:courtify_mobile/services/http_client_factory_web.dart';
// test rebuilt
class AuthService {
  /// Ganti host ini sesuai environment (default: localhost Django)
  static const String baseHost = 'http://127.0.0.1:8000';
  static const String _authBase = '$baseHost/auth/api/flutter/auth';
  static const String _loginUrl = '$_authBase/login/';
  static const String _registerUrl = '$_authBase/register/';
  static const String _logoutUrl = '$_authBase/logout/';
  static const String _meUrl = '$_authBase/me/';

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

  Map<String, String> _parseCookies(String? setCookieHeader) {
    if (setCookieHeader == null || setCookieHeader.isEmpty) return {};
    final cookies = <String, String>{};
    final parts = setCookieHeader.split(',');
    for (final raw in parts) {
      final segment = raw.trim();
      final cookiePair = segment.split(';').first;
      final idx = cookiePair.indexOf('=');
      if (idx > 0) {
        final name = cookiePair.substring(0, idx).trim();
        final value = cookiePair.substring(idx + 1).trim();
        if (name.isNotEmpty && !cookies.containsKey(name)) {
          cookies[name] = value;
        }
      }
    }
    return cookies;
  }

  Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final client = createHttpClient();
      try {
        final response = await client.post(
          Uri.parse(_loginUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        );

        final responseData = Map<String, dynamic>.from(jsonDecode(response.body));
        if (response.statusCode == 200 && responseData['status'] == true) {
          final cookies = _parseCookies(response.headers['set-cookie']);
          final sessionFromBody = responseData['sessionid']?.toString();
          if (sessionFromBody != null && sessionFromBody.isNotEmpty) {
            cookies['sessionid'] = sessionFromBody;
          }
          if (!kIsWeb && cookies.isNotEmpty) {
            await _saveToLocal(_keyCookies, jsonEncode(cookies));
          } else if (kIsWeb) {
            await _saveToLocal(_keyCookies, jsonEncode({'web_session': '1'}));
          }

          final user = Map<String, dynamic>.from(responseData['user'] ?? {});
          await _saveToLocal(_keyRole, user['role']?.toString() ?? '');
          await _saveToLocal(_keyUsername, user['username']?.toString() ?? username);
          responseData['role'] = user['role'];
          responseData['username'] = user['username'] ?? username;
        }
        return responseData;
      } finally {
        client.close();
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final client = createHttpClient();
      try {
        final body = {
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        };
        if (firstName != null && firstName.isNotEmpty) body['first_name'] = firstName;
        if (lastName != null && lastName.isNotEmpty) body['last_name'] = lastName;

        final response = await client.post(
          Uri.parse(_registerUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } finally {
        client.close();
      }
    } catch (e) {
      return {'status': false, 'message': 'Error register: $e'};
    }
  }

  Future<Map<String, dynamic>> fetchCurrentSession() async {
    try {
      final data = await get(_meUrl);
      final user = Map<String, dynamic>.from(data['user'] ?? {});
      if (user.isNotEmpty) {
        await _saveToLocal(_keyRole, user['role']?.toString() ?? '');
        await _saveToLocal(_keyUsername, user['username']?.toString() ?? '');
      }
      return Map<String, dynamic>.from(data);
    } catch (e) {
      return {'status': false, 'message': 'Gagal cek sesi: $e'};
    }
  }

  Future<void> logout() async {
    final client = createHttpClient();
    try {
      final headers = {'Content-Type': 'application/json'};
      final cookiesHeader = await getCookiesHeader();
      if (cookiesHeader.isNotEmpty) {
        headers['Cookie'] = cookiesHeader;
      }
      try {
        await client.post(Uri.parse(_logoutUrl), headers: headers);
      } catch (_) {}
    } finally {
      client.close();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    if (kIsWeb) {
      final username = await _getFromLocal(_keyUsername);
      return username != null && username.isNotEmpty;
    }
    final cookiesJson = await _getFromLocal(_keyCookies);
    if (cookiesJson == null || cookiesJson.isEmpty) return false;
    try {
      final Map<String, dynamic> cookies = jsonDecode(cookiesJson);
      return cookies['sessionid'] != null && cookies['sessionid'].toString().isNotEmpty;
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

  Future<String> getCookiesHeader() async {
    if (kIsWeb) return "";
    final cookiesJson = await _getFromLocal(_keyCookies);
    if (cookiesJson == null || cookiesJson.isEmpty) return "";
    final Map<String, dynamic> cookies = jsonDecode(cookiesJson);
    if (cookies.isEmpty) return "";
    return cookies.entries.map((e) => "${e.key}=${e.value}").join("; ");
  }

  Future<dynamic> get(String url, {bool requireAuth = true}) async {
    final client = createHttpClient();
    try {
      final headers = {'Content-Type': 'application/json'};
      if (!kIsWeb && requireAuth) {
        final cookiesHeader = await getCookiesHeader();
        if (cookiesHeader.isEmpty) {
          throw Exception('No cookies found. User not logged in.');
        }
        headers['Cookie'] = cookiesHeader;
      }

      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return response.body;
        }
      }
      throw Exception('GET request failed: ${response.statusCode} - ${response.body}');
    } finally {
      client.close();
    }
  }

  Future<dynamic> postForm(
    String url,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    final client = createHttpClient();
    try {
      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      if (!kIsWeb && requireAuth) {
        final cookiesHeader = await getCookiesHeader();
        if (cookiesHeader.isEmpty) {
          throw Exception('No cookies found. User not logged in.');
        }
        headers['Cookie'] = cookiesHeader;
      }

      final body = data.map((k, v) => MapEntry(k, v == null ? '' : v.toString()));

      final response = await client.post(
        Uri.parse(url),
        headers: headers,
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
    } finally {
      client.close();
    }
  }

  Future<dynamic> postJson(
    String url,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    final client = createHttpClient();
    try {
      final headers = {'Content-Type': 'application/json'};
      if (!kIsWeb && requireAuth) {
        final cookiesHeader = await getCookiesHeader();
        if (cookiesHeader.isEmpty) {
          throw Exception('No cookies found. User not logged in.');
        }
        headers['Cookie'] = cookiesHeader;
      }

      final response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {};
        return jsonDecode(response.body);
      }
      throw Exception('POST JSON request failed: ${response.statusCode} - ${response.body}');
    } finally {
      client.close();
    }
  }
}
