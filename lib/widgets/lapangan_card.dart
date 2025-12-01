import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class LapanganCard extends StatelessWidget {
  final Lapangan lapangan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LapanganCard({
    super.key,
    required this.lapangan,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              lapangan.fotoUrl ?? "https://via.placeholder.com/400x200",
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lapangan.nama,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tanggal: ${lapangan.jamBuka} - ${lapangan.jamTutup}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  "Status: Tersedia",
                  style: const TextStyle(color: Colors.greenAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  "${lapangan.kategori} • ${lapangan.lokasi}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rp ${lapangan.hargaPerJam} / jam",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: onDelete,
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}