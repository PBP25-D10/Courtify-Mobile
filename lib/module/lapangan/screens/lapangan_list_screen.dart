import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/lapangan/services/api_services.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/module/lapangan/screens/lapangan_form_screen.dart';
import 'package:courtify_mobile/widgets/lapangan_card.dart';

class LapanganListScreen extends StatefulWidget {
  const LapanganListScreen({super.key});

  @override
  State<LapanganListScreen> createState() => _LapanganListScreenState();
}

class _LapanganListScreenState extends State<LapanganListScreen> {
  final LapanganApiService _apiService = LapanganApiService();
  late Future<List<Lapangan>> _futureLapangan;
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _hargaMinController = TextEditingController();
  final TextEditingController _hargaMaxController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedKategori;

  @override
  void initState() {
    super.initState();
    _loadLapangan();
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _hargaMinController.dispose();
    _hargaMaxController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadLapangan() {
    final request = context.read<AuthService>();
    setState(() {
      _futureLapangan = _apiService.getPenyediaLapangan(
        request,
        kategori: _selectedKategori,
        lokasi: _lokasiController.text.trim(),
        hargaMin: _hargaMinController.text.trim(),
        hargaMax: _hargaMaxController.text.trim(),
      );
    });
  }

  void _resetFilters() {
    _selectedKategori = null;
    _lokasiController.clear();
    _hargaMinController.clear();
    _hargaMaxController.clear();
    _searchController.clear();
    _loadLapangan();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _navigateToForm(null),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<Lapangan>>(
              future: _futureLapangan,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLapangan,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Tidak ada lapangan",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final search = _searchController.text.toLowerCase();
                final lapanganList = snapshot.data!
                    .where((l) =>
                        l.nama.toLowerCase().contains(search) ||
                        l.lokasi.toLowerCase().contains(search))
                    .toList();

                if (lapanganList.isEmpty) {
                  return const Center(
                    child: Text(
                      "Tidak ada lapangan sesuai filter.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedKategori,
                  decoration: _inputDecoration("Kategori"),
                  dropdownColor: const Color(0xFF1F2937),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: null, child: Text("Semua")),
                    DropdownMenuItem(value: 'futsal', child: Text('Futsal')),
                    DropdownMenuItem(value: 'basket', child: Text('Basket')),
                    DropdownMenuItem(value: 'badminton', child: Text('Badminton')),
                    DropdownMenuItem(value: 'tenis', child: Text('Tenis')),
                    DropdownMenuItem(value: 'voli', child: Text('Voli')),
                    DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
                  ],
                  onChanged: (v) => setState(() => _selectedKategori = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _lokasiController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Lokasi"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hargaMinController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Harga min"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _hargaMaxController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Harga max"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration("Cari nama atau lokasi"),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _loadLapangan,
                  child: const Text("Terapkan Filter"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  child: const Text("Reset"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1F2937),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
    );
  }

  void _navigateToForm(Lapangan? lapangan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LapanganFormScreen(lapangan: lapangan)),
    ).then((_) => _loadLapangan());
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
              final request = context.read<AuthService>();
              try {
                final response = await _apiService.deleteLapangan(
                  request,
                  lap.idLapangan,
                );

                if (!mounted) return;
                Navigator.pop(context);

                if (response['status'] == 'success') {
                  _loadLapangan();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lapangan berhasil dihapus")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        response['message'] ?? "Gagal menghapus lapangan",
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
