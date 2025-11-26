import 'package:flutter/material.dart';

class BookingUserScreen extends StatelessWidget {
  const BookingUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Saya"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Halaman Riwayat Booking (User)"),
      ),
    );
  }
}