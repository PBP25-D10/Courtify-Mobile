import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/lapangan/services/api_services_lapangan.dart'; // Sesuaikan jika nama file anda api_services_lapangan.dart
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/module/lapangan/screens/lapangan_form_screen.dart';
import 'package:courtify_mobile/widgets/lapangan_card.dart';
// Import AuthService dan LoginScreen
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/screens/login_screen.dart';

class LapanganListScreen extends StatefulWidget {
  const LapanganListScreen({super.key});

  @override
  State<LapanganListScreen> createState() => _LapanganListScreenState();
}

class _LapanganListScreenState extends State<LapanganListScreen> {
  final LapanganApiService _apiService = LapanganApiService();
  final AuthService _authService = AuthService(); // Tambahkan AuthService

  // Buat future nullable karena kita butuh waktu untuk ambil ID dulu
  Future<List<Lapangan>>? _futureLapangan;
  int? _currentUserId; // Simpan ID user di variabel state

  @override
  void initState() {
    super.initState();
    // Panggil fungsi inisialisasi user & data
    _loadUserAndData();
  }

  // Fungsi untuk memuat User ID dari SharedPreferences, lalu ambil data lapangan
  Future<void> _loadUserAndData() async {
    final userId = await _authService.getCurrentUserId();

    if (userId == null) {
      // Jika ID tidak ditemukan (belum login/sesi habis), kembali ke Login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Jika ID ada, simpan ke state dan fetch data API
      setState(() {
        _currentUserId = userId;
        _futureLapangan = _apiService.getPenyediaLapangan(userId);
      });
    }
  }

  void _refreshList() {
    // Refresh menggunakan ID yang sudah disimpan
    if (_currentUserId != null) {
      setState(() {
        _futureLapangan = _apiService.getPenyediaLapangan(_currentUserId!);
      });
    } else {
      _loadUserAndData(); // Coba load ulang user jika id null
    }
  }

  void _handleLogout() async {
    await _authService.logout(); // Hapus sesi
    if (!mounted) return;
    // Kembali ke Login Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text(
          "Daftar Lapangan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF111827),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Logout",
            onPressed: _handleLogout,
          ),
          // Tombol Tambah
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: "Tambah Lapangan",
            onPressed: () => _navigateToForm(null),
          ),
        ],
      ),
      // Cek apakah future sudah di-assign (artinya ID sudah didapat)
      body: _futureLapangan == null
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Loading saat ambil ID
          : FutureBuilder<List<Lapangan>>(
              future: _futureLapangan,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.sports_soccer,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Belum ada lapangan.",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _navigateToForm(null),
                          child: const Text(
                            "Tambah Lapangan Sekarang",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final lapanganList = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lapanganList.length,
                  itemBuilder: (context, index) {
                    final lap = lapanganList[index];
                    return LapanganCard(
                      lapangan: lap,
                      onEdit: () => _navigateToForm(lap),
                      onDelete: () => _deleteLapangan(lap),
                    );
                  },
                );
              },
            ),
    );
  }

  void _navigateToForm(Lapangan? lapangan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LapanganFormScreen(lapangan: lapangan)),
    ).then((_) => _refreshList());
  }

  void _deleteLapangan(Lapangan lap) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Lapangan"),
        content: Text("Apakah Anda yakin ingin menghapus ${lap.nama}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Tutup dialog dulu
                Navigator.pop(context);

                // Panggil API delete
                await _apiService.deleteLapangan(lap.idLapangan);

                // Refresh list
                _refreshList();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lapangan berhasil dihapus")),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
