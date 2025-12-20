import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/iklan/models/iklan.dart'; 

class IklanCard extends StatelessWidget {
  final Iklan iklan;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const IklanCard({
    super.key,
    required this.iklan,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const String baseUrl = 'https://justin-timothy-courtify.pbp.cs.ui.ac.id';

    String? imageUrl;
    if (iklan.banner != null && iklan.banner!.isNotEmpty) {
      if (iklan.banner!.startsWith('http')) {
        imageUrl = iklan.banner;
      } else {
        imageUrl = '$baseUrl${iklan.banner}';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 280,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        elevation: 4,
        color: const Color(0xFF1F2937),
        clipBehavior: Clip.antiAlias, 
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand, 
            children: [
              // 1. Layer Paling Bawah: GAMBAR
              imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover, 
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                              child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        );
                      },
                    )
                  : Container(
                      color: Colors.blueGrey, 
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.white54),
                      ),
                    ),

              // 2. Layer Tengah: GRADIENT (Agar teks putih terbaca)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.8), 
                    ],
                    stops: const [0.0, 0.6, 1.0], 
                  ),
                ),
              ),

              // 3. Layer Teks: Judul & Deskripsi (Kiri Bawah)
              Positioned(
                bottom: 24,
                left: 20,
                right: 60, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Judul Iklan
                    Text(
                      iklan.judul,
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, 
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Deskripsi Iklan
                    Text(
                      iklan.deskripsi,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.white70, 
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 4. Layer Paling Atas: ICON DELETE (Kanan Bawah)
              if (onDelete != null)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      tooltip: "Hapus Iklan",
                     ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}