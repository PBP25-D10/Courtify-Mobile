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
  static const String _baseUrl = 'http://127.0.0.1:8000';

  // Endpoint API yang telah kita buat khusus untuk Flutter di Django
  static const String _loginUrl = '$_baseUrl/auth/api/flutter/login/';
  static const String _registerUrl = '$_baseUrl/auth/api/flutter/register/';
  static const String _logoutUrl = '$_baseUrl/auth/api/flutter/logout/';

  // Key (kunci) string untuk menyimpan data di SharedPreferences
  static const String _keyCookie = 'session_cookie';
  static const String _keyRole = 'user_role';
  static const String _keyUsername = 'user_username';

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
        // Django mengirim cookie 'sessionid' di header 'set-cookie'.
        // Kita harus menangkapnya agar dianggap "sedang login" oleh server.
        String? rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          // Cookie string biasanya panjang (e.g., "sessionid=abc123; Path=/; HttpOnly").
          // Kita hanya butuh bagian sebelum titik koma pertama.
          int indexSemiColon = rawCookie.indexOf(';');
          String sessionCookie = (indexSemiColon == -1) 
              ? rawCookie 
              : rawCookie.substring(0, indexSemiColon);
          
          // Simpan cookie session ini ke penyimpanan HP
          await _saveToLocal(_keyCookie, sessionCookie);
        }
        // ------------------------------------------------

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
    // 1. Ambil cookie session yang sedang tersimpan
    String? sessionCookie = await _getFromLocal(_keyCookie);
    
    // 2. Jika ada cookie, kirim request logout ke server
    if (sessionCookie != null) {
      try {
        await http.post(
          Uri.parse(_logoutUrl),
          headers: {
             'Content-Type': 'application/json',
             // PENTING: Kirim balik cookie session di header agar server tahu siapa yg logout
             'Cookie': sessionCookie, 
          }
        );
      } catch (e) {
        // Jika server error saat logout, biarkan saja, tetap lanjut hapus data lokal.
        print("Warning: Server logout error: $e");
      }
    }

    // 3. HAPUS SEMUA data sesi dari penyimpanan HP (ini yang paling penting di sisi client)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Menghapus cookie, role, dan username yang tersimpan.
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
  // Logikanya: jika ada cookie tersimpan, berarti sedang login.
  Future<bool> isLoggedIn() async {
    String? cookie = await _getFromLocal(_keyCookie);
    return cookie != null && cookie.isNotEmpty;
  }
  
  // Mengambil role user saat ini (misal: 'penyedia' atau 'user')
  Future<String?> getCurrentRole() async {
      return await _getFromLocal(_keyRole);
  }

  // Mengambil username user saat ini untuk ditampilkan di Home Screen
  Future<String?> getCurrentUsername() async {
      return await _getFromLocal(_keyUsername);
  }
}