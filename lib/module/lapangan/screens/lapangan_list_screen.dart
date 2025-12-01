import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    const int penyediaId = 1;
    _futureLapangan = _apiService.getPenyediaLapangan(penyediaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Daftar Lapangan", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF111827),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _navigateToForm(null),
          ),
        ],
      ),
      body: FutureBuilder<List<Lapangan>>(
        future: _futureLapangan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
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
      MaterialPageRoute(
        builder: (_) => LapanganFormScreen(lapangan: lapangan),
      ),
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
                await _apiService.deleteLapangan(lap.idLapangan);
                Navigator.pop(context);
                _refreshList();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Lapangan berhasil dihapus")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _refreshList() {
    setState(() {
      const int penyediaId = 1;
      _futureLapangan = _apiService.getPenyediaLapangan(penyediaId);
    });
  }
}