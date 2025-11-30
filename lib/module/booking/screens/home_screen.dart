import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/booking/services/api_services.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/module/booking/screens/booking_form_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
    final BookingApiService _apiService = BookingApiService(); // ✅ Benar


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Daftar Lapangan", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF111827),
      ),
      body: FutureBuilder<List<Lapangan>>(
        future: _apiService.getLapanganList(),
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
              return _buildLapanganCard(context, lapanganList[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildLapanganCard(BuildContext context, Lapangan lap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // FOTO LAPANGAN
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              lap.fotoUrl ?? "https://via.placeholder.com/400x200",
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // DETAIL LAPANGAN
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lap.nama,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),

                const SizedBox(height: 4),

                Text(
                  "${lap.kategori} • ${lap.lokasi}",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 8),

                Text(
                  "Rp ${lap.hargaPerJam} / jam",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 12),

                // TOMBOL PESAN
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingFormScreen(lapangan: lap),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Pesan Sekarang"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
