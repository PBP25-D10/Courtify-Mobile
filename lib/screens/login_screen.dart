import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- (1) Import ini WAJIB ada
import 'package:courtify_mobile/services/auth_service.dart'; 
import 'package:courtify_mobile/screens/home_user.dart'; 
import 'package:courtify_mobile/screens/home_penyedia.dart'; 
import 'package:courtify_mobile/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password harus diisi!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    // 1. Panggil API Login
    // AuthService hanya bertugas komunikasi ke server & menangkap cookie.
    // Data ID, Role, dll dikembalikan ke sini dalam variabel responseData.
    final responseData = await _authService.login(username, password);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (responseData['status'] == true) {
      // === LOGIN SUKSES ===
      
      // 2. AMBIL DATA DARI RESPONSE SERVER
      // Pastikan server Django mengirim key 'id' (integer), 'role', dan 'username'
      int userId = responseData['id']; 
      String role = responseData['role'];
      String successUsername = responseData['username'];

      // 3. SIMPAN ID DAN DATA LAINNYA SECARA MANUAL (TERLIHAT JELAS DI SINI)
      final prefs = await SharedPreferences.getInstance();
      
      // Simpan User ID (Penting untuk fetch data nanti)
      // Kita ubah ke String agar aman, atau gunakan setInt jika yakin ID selalu angka
      await prefs.setString('user_id', userId.toString()); 
      print("User ID disimpan: $userId"); // Debugging di console

      // Simpan Role & Username
      await prefs.setString('user_role', role);
      await prefs.setString('user_username', successUsername);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login berhasil! Hai, $successUsername.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // 4. NAVIGASI SESUAI ROLE
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role tidak dikenali: $role'), backgroundColor: Colors.orange),
        );
      }
    } else {
      // === LOGIN GAGAL ===
      String message = responseData['message'] ?? 'Terjadi kesalahan saat login.';
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login Gagal'),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827), // Dark Theme
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.sports_tennis_rounded, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                "Selamat Datang di Courtify",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                "Silakan login untuk melanjutkan",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Username Field
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.blueAccent),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.black87),
                onSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                    : ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("MASUK", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
              ),
              const SizedBox(height: 20),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? ", style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text("Daftar di sini", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
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