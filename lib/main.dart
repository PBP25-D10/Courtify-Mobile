import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
// IMPORT PENTING: Mengimpor halaman login agar bisa dijadikan halaman awal
import 'package:courtify_mobile/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Widget ini adalah akar (root) dari aplikasi Anda.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        AuthService authService = AuthService();
        return authService;
      },
      child: MaterialApp(
        // Ganti judul aplikasi
        title: 'Courtify App',
        // Menghilangkan banner 'debug' di pojok kanan atas (opsional)
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Mengatur tema warna aplikasi menjadi berbasis biru
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
          // Mengatur gaya AppBar secara global (opsional)
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            elevation: 2,
          )
        ),
        // BAGIAN PENTING:
        // Mengatur 'home' (halaman yang pertama kali dimuat) ke LoginScreen
        home: const LoginScreen(),
      ),
    );
  }
}