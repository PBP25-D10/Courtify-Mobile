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
  final TextEditingController _searchController = TextEditingController();
  String _selectedKategori = "Semua";
  RangeValues? _priceRange;

  @override
  void initState() {
    super.initState();
    _loadLapangan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadLapangan() {
    final request = context.read<AuthService>();
    setState(() {
      _futureLapangan = _apiService.getPenyediaLapangan(request);
    });
  }

  List<Lapangan> _applyFilters(List<Lapangan> data, RangeValues effectiveRange) {
    return data.where((lap) {
      final q = _searchController.text.toLowerCase();
      final matchesQuery = q.isEmpty ||
          lap.nama.toLowerCase().contains(q) ||
          lap.lokasi.toLowerCase().contains(q) ||
          lap.kategori.toLowerCase().contains(q);
      final matchesKategori =
          _selectedKategori == "Semua" || lap.kategori == _selectedKategori;
      final matchesPrice = lap.hargaPerJam >= effectiveRange.start &&
          lap.hargaPerJam <= effectiveRange.end;
      return matchesQuery && matchesKategori && matchesPrice;
    }).toList();
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
      ),
      body: FutureBuilder<List<Lapangan>>(
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

          final lapanganList = snapshot.data!;
          final prices = lapanganList.map((e) => e.hargaPerJam).toList();
          final minPrice = prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b).toDouble() : 0.0;
          final maxPrice = prices.isNotEmpty ? prices.reduce((a, b) => a > b ? a : b).toDouble() : 0.0;
          final categories = ["Semua", ...{...lapanganList.map((e) => e.kategori)}];
          final baseRange = maxPrice == minPrice
              ? RangeValues(minPrice, minPrice + 1)
              : RangeValues(minPrice, maxPrice);
          final RangeValues effectiveRange = _priceRange ?? baseRange;
          final filteredList = _applyFilters(lapanganList, effectiveRange);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Cari nama, lokasi, atau kategori",
                        hintStyle: const TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: const Color(0xFF111827),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: categories.contains(_selectedKategori) ? _selectedKategori : "Semua",
                      dropdownColor: const Color(0xFF111827),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Kategori",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF111827),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: categories
                          .map((k) => DropdownMenuItem(value: k, child: Text(k, overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedKategori = v ?? "Semua"),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Rentang harga: Rp ${effectiveRange.start.toStringAsFixed(0)} - Rp ${effectiveRange.end.toStringAsFixed(0)}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    RangeSlider(
                      values: effectiveRange,
                      min: minPrice,
                      max: maxPrice == minPrice ? minPrice + 1 : maxPrice,
                      divisions: (maxPrice - minPrice).abs() > 0 ? 10 : null,
                      activeColor: const Color(0xFF2563EB),
                      inactiveColor: Colors.white24,
                      labels: RangeLabels(
                        effectiveRange.start.toStringAsFixed(0),
                        effectiveRange.end.toStringAsFixed(0),
                      ),
                      onChanged: (values) {
                        setState(() => _priceRange = values);
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() {}),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Filter", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _selectedKategori = "Semua";
                                _priceRange = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Reset", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (filteredList.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "Tidak ada lapangan yang cocok dengan filter",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else
                ...filteredList.map(
                  (lap) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LapanganCard(
                      lapangan: lap,
                      onEdit: () => _navigateToForm(lap),
                      onDelete: () => _deleteLapangan(lap),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(null),
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add),
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
