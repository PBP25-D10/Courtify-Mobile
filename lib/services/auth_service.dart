import 'dart:convert'; // Untuk mengubah data ke/dari format JSON
import 'package:http/http.dart' as http; // Untuk melakukan request API ke Django
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan data sesi di memori HP
import 'package:flutter/foundation.dart'; // <--- TAMBAHAN untuk kIsWeb

class AuthService {
  // =================================================================
  // KONFIGURASI URL SERVER (PENTING!)
  // =================================================================
  // Menggunakan getter agar bisa menyesuaikan base URL dengan environment (Web/Emulator)
  String get _baseUrl {
    // KIsWeb adalah true jika aplikasi berjalan di web
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    }
    // Asumsi: 10.0.2.2 untuk Android Emulator
    return "http://10.0.2.2:8000";
  }

  // Endpoint API yang telah kita buat khusus untuk Flutter di Django
  // Harus: /auth/api/flutter/login/
  String get _loginUrl => '$_baseUrl/auth/api/flutter/login/';
  String get _registerUrl => '$_baseUrl/auth/api/flutter/register/';
  String get _logoutUrl => '$_baseUrl/auth/api/flutter/logout/';

  // Key (kunci) string untuk menyimpan data di SharedPreferences
  static const String _keyCookie = 'session_cookie';
  static const String _keyRole = 'user_role';
  static const String _keyUsername = 'user_username';
  static const String _keyUserId = 'user_id'; // <--- TAMBAHAN KRUSIAL: Menyimpan ID User

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
        
        // --- BAGIAN KRUSIAL: MENANGKAP COOKIE SESSION ---
        String? rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          int indexSemiColon = rawCookie.indexOf(';');
          String sessionCookie = (indexSemiColon == -1) 
              ? rawCookie 
              : rawCookie.substring(0, indexSemiColon);
          await _saveToLocal(_keyCookie, sessionCookie);
        }
        
        // 4. Simpan 'role', 'username', dan ID yang dikirim balik oleh Django
        
        // <--- TAMBAHAN KRUSIAL: SIMPAN USER ID
        if (responseData.containsKey('id')) {
           await _saveToLocal(_keyUserId, responseData['id'].toString());
        }

        if (responseData.containsKey('role')) {
           await _saveToLocal(_keyRole, responseData['role']);
        }
        if (responseData.containsKey('username')) {
           await _saveToLocal(_keyUsername, responseData['username']);
        }
      }

      // 5. Kembalikan data JSON mentah ke UI untuk diproses (misal untuk navigasi)
      return responseData;

    } catch (e) {
      // Tangani error jaringan (server mati, tidak ada internet, dll)
      return {'status': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // =================================================================
  // FUNGSI UTAMA: REGISTER (Tetap sama, tidak ada perubahan)
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
          'role': role,
        }),
      );
      
      return jsonDecode(response.body);

    } catch (e) {
      return {'status': false, 'message': 'Error register: $e'};
    }
  }

  // =================================================================
  // FUNGSI UTAMA: LOGOUT (Tetap sama, 'clear()' otomatis menghapus ID)
  // =================================================================
  Future<void> logout() async {
    String? sessionCookie = await _getFromLocal(_keyCookie);
    
    if (sessionCookie != null) {
      try {
        await http.post(
          Uri.parse(_logoutUrl),
          headers: {
             'Content-Type': 'application/json',
             'Cookie': sessionCookie, 
          }
        );
      } catch (e) {
        print("Warning: Server logout error: $e");
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
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
  
  // <--- TAMBAHAN KRUSIAL: MENGAMBIL USER ID
  Future<int?> getCurrentUserId() async {
    String? idStr = await _getFromLocal(_keyUserId);
    // Coba konversi ke integer. Jika gagal (misal null), kembalikan null.
    if (idStr != null) return int.tryParse(idStr);
    return null;
  }

  Future<bool> isLoggedIn() async {
    String? cookie = await _getFromLocal(_keyCookie);
    return cookie != null && cookie.isNotEmpty;
  }
  
  Future<String?> getCurrentRole() async {
      return await _getFromLocal(_keyRole);
  }

  Future<String?> getCurrentUsername() async {
      return await _getFromLocal(_keyUsername);
  }
}