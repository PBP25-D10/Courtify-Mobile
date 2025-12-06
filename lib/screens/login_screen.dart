import 'package:flutter/material.dart';
// Import service untuk komunikasi backend
import 'package:courtify_mobile/services/auth_service.dart';
// Import halaman tujuan navigasi
import 'package:courtify_mobile/screens/home_user.dart';
import 'package:courtify_mobile/screens/home_penyedia.dart';
import 'package:courtify_mobile/screens/register_screen.dart';
// Import halaman register jika sudah ada (jika belum, biarkan di-komen)
// import 'package:courtify_mobile/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk mengambil teks dari input field
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instance dari AuthService
  final AuthService _authService = AuthService();

  // Status untuk menampilkan loading spinner
  bool _isLoading = false;
  // Status untuk menyembunyikan/menampilkan password
  bool _obscurePassword = true;

  // Fungsi yang dijalankan saat tombol Login ditekan
  void _handleLogin() async {
    // 1. Validasi Input Dasar
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan Password harus diisi!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Ubah status menjadi loading (munculkan spinner)
    setState(() {
      _isLoading = true;
    });
    // Tutup keyboard jika terbuka
    FocusScope.of(context).unfocus();

    // 3. Panggil API Login via AuthService
    // (AuthService akan menangkap cookie session secara otomatis)
    final responseData = await _authService.login(username, password);

    // 4. Kembalikan status loading (hilangkan spinner)
    setState(() {
      _isLoading = false;
    });

    // Cek apakah widget masih aktif sebelum menggunakan 'context' setelah await
    if (!mounted) return;

    // 5. Cek respons dari server
    if (responseData['status'] == true) {
      // === LOGIN SUKSES ===

      // Ambil data penting dari respons JSON
      String role = responseData['role'];
      String successUsername = responseData['username'];

      // Tampilkan pesan sukses sekilas
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login berhasil! Hai, $successUsername.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // === LOGIKA NAVIGASI BERDASARKAN ROLE ===
      // Kita gunakan pushReplacement agar pengguna tidak bisa kembali
      // ke halaman login dengan menekan tombol 'Back'.
      if (role == 'penyedia') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePenyediaScreen()),
        );
      } else if (role == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeUserScreen()),
        );
      } else {
        // Fallback jika role tidak dikenali
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role tidak dikenali: $role. Hubungi admin.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // === LOGIN GAGAL ===
      // Tampilkan pesan error yang dikirim dari Django
      String message =
          responseData['message'] ?? 'Terjadi kesalahan saat login.';
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login Gagal'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ], ////
        ),
      );
    }
  }

  @override
  void dispose() {
    // Bersihkan controller saat widget dihancurkan untuk mencegah kebocoran memori
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan SingleChildScrollView agar tidak overflow saat keyboard muncul di HP kecil
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Bagian Header/Logo ---
              const Icon(
                Icons.sports_tennis_rounded, // Ganti ikon sesuai tema aplikasi
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                "Selamat Datang di Courtify",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Silakan login untuk melanjutkan",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // --- Bagian Form Input ---
              // Input Username
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),

              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword, // Menyembunyikan teks
                textInputAction: TextInputAction.done,
                // Saat tombol enter ditekan di keyboard, langsung coba login
                onSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  // Tombol mata untuk melihat/menyembunyikan password
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 30),

              // --- Tombol Login ---
              // Menampilkan CircularProgressIndicator jika sedang loading,
              // jika tidak, tampilkan ElevatedButton.
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "MASUK",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),

              // --- Tombol Navigasi ke Register ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun?"),
                  TextButton(
                    onPressed: () {
                      // Navigasi ke halaman register jika sudah dibuat
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Daftar di sini",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
