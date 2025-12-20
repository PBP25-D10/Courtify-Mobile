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
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageBlock(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lapangan.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${lapangan.kategori} - ${lapangan.lokasi}', maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('Rp ${lapangan.hargaPerJam} / jam', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Jam buka ${lapangan.jamBuka} - ${lapangan.jamTutup}'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(onPressed: onEdit, child: const Text('Edit')),
                    ElevatedButton(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Hapus'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageBlock() {
    if (lapangan.fotoUrl == null) {
      return Container(
        height: 160,
        width: double.infinity,
        alignment: Alignment.center,
        color: const Color(0xFFE5E7EB),
        child: const Text("Tidak ada foto"),
      );
    }

    return Image.network(
      lapangan.fotoUrl!,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 160,
        width: double.infinity,
        alignment: Alignment.center,
        color: const Color(0xFFE5E7EB),
        child: const Text("Gagal load foto"),
      ),
    );
  }
}
