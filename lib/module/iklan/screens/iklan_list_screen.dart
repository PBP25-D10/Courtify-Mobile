import 'package:courtify_mobile/widgets/right_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/iklan/services/iklan_api_services.dart'; 
import 'package:courtify_mobile/module/iklan/models/iklan.dart';
import 'package:courtify_mobile/module/iklan/widgets/iklan_card.dart';
import 'package:courtify_mobile/module/iklan/screens/iklan_form_screen.dart';

class IklanListScreen extends StatefulWidget {
  const IklanListScreen({super.key});

  @override
  State<IklanListScreen> createState() => _IklanListScreenState();
}

class _IklanListScreenState extends State<IklanListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final IklanApiService _apiService = IklanApiService();
  late Future<List<Iklan>> _futureIklan;

  String _searchQuery = "";
  String _selectedTimeFilter = "Semua Waktu";
  final List<String> _timeFilters = ["Semua Waktu", "Hari Ini", "Minggu Ini", "Lebih Lama"];
  
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  final int _itemsPerPage = 3;

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
      _currentPage = 1; 
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF111827);
    const primaryBlue = Color(0xFF2563EB); 
    const borderColor = Color(0xFFFFFFFF);

    return Scaffold(
      key: _scaffoldKey, 
      backgroundColor: backgroundColor,
      endDrawer: RightDrawer(), 
      body: SafeArea(
        child: Column(
          children: [
            // --- FIXED HEADER (Tidak ikut discroll) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Courtify",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
            ),

            // --- SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TITLE & ADD BUTTON ---
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Iklan",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToForm(null),
                            icon: const Icon(Icons.add, size: 18, color: Colors.white),
                            label: const Text("Iklan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB).withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- FILTER SECTION ---
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.5), 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.transparent), 
                      ),
                      child: Column(
                        children: [
                          // Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.transparent), 
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTimeFilter,
                                dropdownColor: const Color(0xFF111827),
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
                                    _currentPage = 1;
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
                              hintText: "Cari judul atau nama lapangan",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: const Color(0xFF111827),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none, 
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
                                       _currentPage = 1;
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

                    // --- LIST CONTENT & PAGINATION ---
                    FutureBuilder<List<Iklan>>(
                      future: _futureIklan,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator())
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: Text("Belum ada iklan.", style: TextStyle(color: Colors.white)))
                          );
                        }

                        final filteredList = _applyFilters(snapshot.data!);

                        if (filteredList.isEmpty) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: Text("Tidak ada iklan yang cocok dengan filter.", style: TextStyle(color: Colors.white)))
                          );
                        }

                        final int totalItems = filteredList.length;
                        final int totalPages = (totalItems / _itemsPerPage).ceil();
                        
                        if (_currentPage > totalPages) _currentPage = totalPages;
                        if (_currentPage < 1) _currentPage = 1;

                        final int startIndex = (_currentPage - 1) * _itemsPerPage;
                        final int endIndex = (startIndex + _itemsPerPage < totalItems) 
                            ? startIndex + _itemsPerPage 
                            : totalItems;
                        
                        final List<Iklan> paginatedList = filteredList.sublist(startIndex, endIndex);

                        return Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(), 
                              itemCount: paginatedList.length,
                              itemBuilder: (context, index) {
                                final iklan = paginatedList[index];
                                
                                return IklanCard(
                                  iklan: iklan,
                                  // Navigasi ke form edit saat card ditekan
                                  onTap: () {
                                    _navigateToForm(iklan);
                                  },
                                  onDelete: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      barrierColor: Colors.black.withOpacity(0.7), 
                                      builder: (context) => Dialog(
                                        backgroundColor: const Color(0xFF111827),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [                                              
                                              const Text(
                                                "Konfirmasi Hapus",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              const Text(
                                                "Apakah Anda yakin ingin menghapus?",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 32),
                                              
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: const Color(0xFF6B7280),
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                    ),
                                                    child: const Text(
                                                      "Batal",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),),
                                                  ),
                          
                                                  const SizedBox(width: 8),
                                                 
                                                  ElevatedButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFFEB257B),
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                      elevation: 0,
                                                    ),
                                                    child: const Text(
                                                      "Hapus", 
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      )
                                                    ),
                                                  ),
                                                  
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );

                                    // Jika user pilih Hapus, panggil API
                                    if (confirm == true) {
                                      try {
                                        final request = context.read<AuthService>();
                                        final api = IklanApiService();
                                        
                                        await api.deleteIklan(request, iklan.pk);

                                        if (mounted) {
                                          _loadIklan();
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Iklan berhasil dihapus!")),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Gagal menghapus: $e")),
                                          );
                                        }
                                      }
                                    }
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Pagination Controls
                            if (totalPages > 1)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: _currentPage > 1 
                                        ? () => setState(() => _currentPage--) 
                                        : null,
                                      child: Text(
                                        "<", 
                                        style: TextStyle(
                                          color: _currentPage > 1 ? Colors.white : Colors.grey,
                                          fontSize: 14
                                        )
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 8),

                                    Row(
                                      children: List.generate(totalPages, (index) {
                                        final pageNum = index + 1;
                                        return GestureDetector(
                                          onTap: () => setState(() => _currentPage = pageNum),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: const BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            child: Text(
                                              "$pageNum",
                                              style: TextStyle(
                                                color: _currentPage == pageNum ? Colors.white : Colors.grey,
                                                fontWeight: _currentPage == pageNum ? FontWeight.bold : FontWeight.normal,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),

                                    const SizedBox(width: 8),

                                    TextButton(
                                      onPressed: _currentPage < totalPages 
                                        ? () => setState(() => _currentPage++) 
                                        : null,
                                      child: Text(
                                        ">", 
                                        style: TextStyle(
                                          color: _currentPage < totalPages ? Colors.white : Colors.grey,
                                          fontSize: 14
                                        )
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // --- FOOTER ---
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          "© 2025 Courtify. All rights reserved. | Kebijakan Privasi | Peta Situs",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToForm(Iklan? iklan) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IklanFormScreen(iklan: iklan, lapangan: null), 
      ),
    );
    
    _loadIklan();
  }
}