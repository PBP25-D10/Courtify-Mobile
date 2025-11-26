import 'package:flutter/material.dart';

class BookingPenyediaScreen extends StatelessWidget {
  const BookingPenyediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Masuk"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Halaman Kelola Booking (Penyedia)"),
      ),
    );
  }
}