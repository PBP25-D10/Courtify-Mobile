import 'dart:convert'; // Untuk mengubah data ke/dari format JSON
import 'package:http/http.dart' as http; // Untuk melakukan request API ke Django
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan data sesi di memori HP

class AuthService {
  // =================================================================
  // KONFIGURASI URL SERVER (PENTING!)
  // =================================================================
  // Ganti IP ini sesuai lingkungan pengembangan Anda:
  // - Gunakan '10.0.2.2' jika menjalankan di Android Emulator.
  // - Gunakan IP LAN laptop Anda (misal: '192.168.1.X') jika menggunakan HP fisik atau iOS Simulator.
  // - JANGAN gunakan 'localhost' atau '127.0.0.1' di sini.
  static const String _baseUrl = 'https://justin-timothy-courtify.pbp.cs.ui.ac.id';

  // Endpoint API yang telah kita buat khusus untuk Flutter di Django
  static const String _loginUrl = '$_baseUrl/auth/api/flutter/login/';
  static const String _registerUrl = '$_baseUrl/auth/api/flutter/register/';
  static const String _logoutUrl = '$_baseUrl/auth/api/flutter/logout/';

  // Key (kunci) string untuk menyimpan data di SharedPreferences
  static const String _keyCookies = 'all_cookies'; // Store all cookies as JSON
  static const String _keyRole = 'user_role';
  static const String _keyUsername = 'user_username';
  static const String _keyUserData = 'user_data';

  // =================================================================
  // FUNGSI UTAMA: LOGIN
  // =================================================================
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // 1. Kirim request POST dengan data username & password dalam format JSON
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      // 2. Decode respons JSON dari server
      final responseData = jsonDecode(response.body);

      // 3. Cek jika login berhasil (status code 200 DAN status: true di JSON)
      if (response.statusCode == 200 && responseData['status'] == true) {

      // --- BAGIAN KRUSIAL: MENANGKAP SEMUA COOKIES (FIX) ---
      // NOTE: response.headers['set-cookie'] sering digabung jadi 1 string,
      // dan atribut Expires punya koma, jadi split(',') itu BISA RUSAK.
      // Kita ambil cookie pakai regex yang aman.
      final String? setCookieHeader = response.headers['set-cookie'];

      if (setCookieHeader != null && setCookieHeader.isNotEmpty) {
        final Map<String, String> cookies = {};

        final RegExp cookieRegex = RegExp(r'(^|,)\s*([^=;\s]+)=([^;]+)');
        for (final match in cookieRegex.allMatches(setCookieHeader)) {
          final String name = match.group(2)!;
          final String value = match.group(3)!;

          // Safety: kalau ada atribut yang ikut ketangkap (harusnya tidak), skip saja
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
      } else {
        // Biar jelas kalau login sukses tapi server tidak kirim cookie
        throw Exception('Login berhasil tapi Set-Cookie tidak ada. Cek backend login endpoint.');
      }
      // ----------------------------------------------------


        // 4. Simpan 'role' dan 'username' yang dikirim balik oleh Django
        // Data ini penting untuk navigasi UI dan tampilan Home screen.
        await _saveToLocal(_keyRole, responseData['role']);
        await _saveToLocal(_keyUsername, responseData['username']);
      }

      // 5. Kembalikan data JSON mentah ke UI untuk diproses (misal untuk navigasi)
      return responseData;

    } catch (e) {
      // Tangani error jaringan (server mati, tidak ada internet, dll)
      return {'status': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // =================================================================
  // FUNGSI UTAMA: REGISTER
  // =================================================================
  Future<Map<String, dynamic>> register(String username, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse(_registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'role': role, // Role wajib dikirim ('user' atau 'penyedia') saat register
        }),
      );
      
      // Mengembalikan respons JSON dari server (sukses atau error validasi)
      return jsonDecode(response.body);

    } catch (e) {
      return {'status': false, 'message': 'Error register: $e'};
    }
  }

  // =================================================================
  // FUNGSI UTAMA: LOGOUT
  // =================================================================
  Future<void> logout() async {
    // 1. Ambil cookies yang sedang tersimpan
    String? cookiesJson = await _getFromLocal(_keyCookies);

    // 2. Jika ada cookies, kirim request logout ke server
    if (cookiesJson != null) {
      try {
        Map<String, String> cookies = Map<String, String>.from(jsonDecode(cookiesJson));
        String cookieHeader = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

        await http.post(
          Uri.parse(_logoutUrl),
          headers: {
             'Content-Type': 'application/json',
             // PENTING: Kirim balik cookies di header agar server tahu siapa yg logout
             'Cookie': cookieHeader,
           }
        );
      } catch (e) {
        // Jika server error saat logout, biarkan saja, tetap lanjut hapus data lokal.
        print("Warning: Server logout error: $e");
      }
    }

    // 3. HAPUS SEMUA data sesi dari penyimpanan HP (ini yang paling penting di sisi client)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Menghapus cookies, role, dan username yang tersimpan.
  }


  // =================================================================
  // HELPER FUNCTIONS (Penyimpanan Lokal & Status)
  // =================================================================
  
  // Fungsi privat untuk menyimpan string ke SharedPreferences
  Future<void> _saveToLocal(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Fungsi privat untuk mengambil string dari SharedPreferences
  Future<String?> _getFromLocal(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // --- FUNGSI PUBLIK UNTUK UI ---

  // Cek apakah user sedang login (berguna untuk Splash Screen)
  // Logikanya: jika ada cookies tersimpan, berarti sedang login.
  Future<bool> isLoggedIn() async {
    String? cookiesJson = await _getFromLocal(_keyCookies);
    if (cookiesJson != null) {
      try {
        Map<String, String> cookies = Map<String, String>.from(jsonDecode(cookiesJson));
        return cookies.isNotEmpty;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
  
  // Mengambil role user saat ini (misal: 'penyedia' atau 'user')
  Future<String?> getCurrentRole() async {
      return await _getFromLocal(_keyRole);
  }

  // Mengambil username user saat ini untuk ditampilkan di Home Screen
  Future<String?> getCurrentUsername() async {
      return await _getFromLocal(_keyUsername);
  }

  // =================================================================
  // HTTP REQUEST METHODS (menggantikan CookieRequest)
  // =================================================================

  // Property untuk mengakses data user (seperti jsonData di CookieRequest)
  Future<Map<String, dynamic>> getJsonData() async {
    // Untuk kompatibilitas, kembalikan data user yang tersimpan
    String? username = await _getFromLocal(_keyUsername);
    String? role = await _getFromLocal(_keyRole);
    return {
      'username': username,
      'role': role,
    };
  }

  // Method GET dengan cookie
  Future<dynamic> get(String url) async {
    String? cookiesJson = await _getFromLocal(_keyCookies);
    if (cookiesJson == null) {
      throw Exception('No cookies found. User not logged in.');
    }

    Map<String, String> cookies = Map<String, String>.from(jsonDecode(cookiesJson));
    String cookieHeader = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Cookie': cookieHeader,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Coba parse sebagai JSON, jika gagal return sebagai string
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    } else {
      throw Exception('GET request failed: ${response.statusCode} - ${response.body}');
    }
  }

  // Method POST dengan cookie
  Future<dynamic> post(String url, Map<String, dynamic> data) async {
    String? cookiesJson = await _getFromLocal(_keyCookies);
    if (cookiesJson == null) {
      throw Exception('No cookies found. User not logged in.');
    }

    Map<String, String> cookies = Map<String, String>.from(jsonDecode(cookiesJson));
    String cookieHeader = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Cookie': cookieHeader,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    } else {
      throw Exception('POST request failed: ${response.statusCode} - ${response.body}');
    }
  }

  // Method POST JSON dengan cookie (untuk data yang sudah dalam format JSON string)
  Future<dynamic> postJson(String url, String jsonData) async {
    String? cookiesJson = await _getFromLocal(_keyCookies);
    if (cookiesJson == null) {
      throw Exception('No cookies found. User not logged in.');
    }

    Map<String, String> cookies = Map<String, String>.from(jsonDecode(cookiesJson));
    String cookieHeader = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Cookie': cookieHeader,
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    } else {
      throw Exception('POST JSON request failed: ${response.statusCode} - ${response.body}');
    }
  }

}