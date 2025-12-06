import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/iklan/services/api_services.dart';
import 'package:courtify_mobile/module/iklan/models/iklan.dart';
import 'package:courtify_mobile/module/iklan/widgets/iklan_card.dart';
import 'package:courtify_mobile/module/iklan/screens/iklan_form_screen.dart';

class IklanListScreen extends StatefulWidget {
  const IklanListScreen({super.key});

  @override
  State<IklanListScreen> createState() => _IklanListScreenState();
}

class _IklanListScreenState extends State<IklanListScreen> {
  final IklanApiService _apiService = IklanApiService();
  late Future<List<Iklan>> _futureIklan;

  String _searchQuery = "";
  String _selectedTimeFilter = "Semua Waktu";
  final List<String> _timeFilters = ["Semua Waktu", "Hari Ini", "Minggu Ini", "Lebih Lama"];
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIklan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadIklan() {
    final request = context.read<AuthService>();
    setState(() {
      _futureIklan = _apiService.fetchIklan(request);
    });
  }

  List<Iklan> _applyFilters(List<Iklan> data) {
    return data.where((iklan) {
      final bool matchesSearch = iklan.judul.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesTime = true;
      final now = DateTime.now();
      final difference = now.difference(iklan.tanggal).inDays;

      if (_selectedTimeFilter == "Hari Ini") {
        matchesTime = difference == 0 && now.day == iklan.tanggal.day;
      } else if (_selectedTimeFilter == "Minggu Ini") {
        matchesTime = difference <= 7;
      } else if (_selectedTimeFilter == "Lebih Lama") {
        matchesTime = difference > 7;
      }

      return matchesSearch && matchesTime;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = "";
      _searchController.clear();
      _selectedTimeFilter = "Semua Waktu";
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF111827);
    const primaryBlue = Color(0xFF3758F9); 

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Iklan",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.campaign, color: Colors.white24, size: 40),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToForm(null),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Iklan", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF253B80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- FILTER SECTION ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF212B45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTimeFilter,
                        dropdownColor: const Color(0xFF1F2937),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        style: const TextStyle(color: Colors.white),
                        items: _timeFilters.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedTimeFilter = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Cari judul iklan...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: const Color(0xFF111827),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade700),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                             setState(() {
                               _searchQuery = _searchController.text;
                             });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Filter Iklan", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _resetFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Reset", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- LIST CONTENT ---
            Expanded(
              child: FutureBuilder<List<Iklan>>(
                future: _futureIklan,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Belum ada iklan.", style: TextStyle(color: Colors.white)));
                  }

                  final filteredList = _applyFilters(snapshot.data!);

                  if (filteredList.isEmpty) {
                    return const Center(child: Text("Tidak ada iklan yang cocok dengan filter.", style: TextStyle(color: Colors.white)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final iklan = filteredList[index];
                      return IklanCard(
                        iklan: iklan,
                        onTap: () => _navigateToForm(iklan),
                        onDelete: () => _deleteIklan(iklan),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(Iklan? iklan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IklanFormScreen(iklan: iklan, lapangan: null), 
      ),
    ).then((_) => _loadIklan()); 
  }

  // --- LOGIC DELETE & MODAL POP-UP ---
  void _deleteIklan(Iklan iklan) {
    showDialog(
      context: context,
      // 1. BARRIER COLOR: Ini yang membuat background menjadi hitam gelap transparan
      barrierColor: Colors.black.withOpacity(0.7), 
      builder: (context) => Dialog(
        // Menggunakan Dialog (bukan AlertDialog) agar lebih mudah custom shape dan warna
        backgroundColor: const Color(0xFF262626), // Warna gelap abu-abu pekat
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 350), // Membatasi lebar agar rapi
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Judul
              const Text(
                "Konfirmasi Hapus",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Isi Pesan
              const Text(
                "Apakah Anda yakin untuk menghapus?",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Tombol Aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tombol TIDAK (Abu-abu)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B7280), // Abu-abu slate
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Tidak"),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Tombol YA (Pink/Merah)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // Tutup dialog
                        
                        final request = context.read<AuthService>();
                        try {
                          final response = await _apiService.deleteIklan(request, iklan.pk);
                          if (!mounted) return;
                          
                          if (response['status'] == 'success' || response['success'] == true) {
                            _loadIklan(); 
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Iklan berhasil dihapus")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response['message'] ?? "Gagal menghapus iklan")),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD63E6D), // Warna Pink
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Ya"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}