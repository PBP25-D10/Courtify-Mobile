// import 'package:flutter/material.dart';
// import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
// import 'package:courtify_mobile/module/booking/services/api_services_booking.dart';

// class BookingFormScreen extends StatefulWidget {
//   final Lapangan lapangan;
//   // 1. Tambahkan parameter cookies
//   final Map<String, String> cookies;

//   const BookingFormScreen({
//     super.key,
//     required this.lapangan,
//     required this.cookies, // Wajib diisi
//   });

//   @override
//   State<BookingFormScreen> createState() => _BookingFormScreenState();
// }

// class _BookingFormScreenState extends State<BookingFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final BookingApiService _apiService = BookingApiService();
  
//   // State Form
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _timeMulai = const TimeOfDay(hour: 8, minute: 0);
//   TimeOfDay _timeSelesai = const TimeOfDay(hour: 10, minute: 0);
//   bool _isLoading = false;

//   // Fungsi Submit
//   void _submitBooking() async {
//     setState(() => _isLoading = true);

//     // Format tanggal YYYY-MM-DD
//     String dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

//     Map<String, dynamic> payload = {
//       // Pastikan key ini sesuai form Django kamu
//       //"lapangan": widget.lapangan.id, // atau "lapangan_id" tergantung backend
//       "tanggal": dateStr,
//       "jam_mulai": _timeMulai.hour, // Kirim integer jam
//       "jam_selesai": _timeSelesai.hour, 
//     };

//     try {
//       // 2. Panggil API dengan Cookies
//       final response = await _apiService.createBooking(payload, widget.cookies);

//       if (!mounted) return;

//       if (response['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Berhasil!"), backgroundColor: Colors.green));
//         Navigator.pop(context); // Kembali ke list
//       } else {
//         // Tampilkan error dari Django (misal: Bentrok jam)
//         String msg = response['message'] ?? "Gagal booking.";
//         if(response['errors'] != null) msg += " ${response['errors']}";
        
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF111827),
//       appBar: AppBar(
//         title: Text("Booking ${widget.lapangan.nama}"),
//         backgroundColor: const Color(0xFF111827),
//         iconTheme: const IconThemeData(color: Colors.white),
//         titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Pilih Tanggal
//             ListTile(
//               title: const Text("Tanggal", style: TextStyle(color: Colors.white)),
//               subtitle: Text("${_selectedDate.toLocal()}".split(' ')[0], style: const TextStyle(color: Colors.grey)),
//               trailing: const Icon(Icons.calendar_today, color: Colors.blueAccent),
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: _selectedDate,
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime(2026),
//                 );
//                 if (picked != null) setState(() => _selectedDate = picked);
//               },
//             ),
//             const Divider(color: Colors.grey),

//             // Pilih Jam Mulai
//             ListTile(
//               title: const Text("Jam Mulai", style: TextStyle(color: Colors.white)),
//               subtitle: Text("${_timeMulai.format(context)}", style: const TextStyle(color: Colors.grey)),
//               trailing: const Icon(Icons.access_time, color: Colors.blueAccent),
//               onTap: () async {
//                 final picked = await showTimePicker(context: context, initialTime: _timeMulai);
//                 if (picked != null) setState(() => _timeMulai = picked);
//               },
//             ),
            
//             // Pilih Jam Selesai
//             ListTile(
//               title: const Text("Jam Selesai", style: TextStyle(color: Colors.white)),
//               subtitle: Text("${_timeSelesai.format(context)}", style: const TextStyle(color: Colors.grey)),
//               trailing: const Icon(Icons.access_time_filled, color: Colors.blueAccent),
//               onTap: () async {
//                 final picked = await showTimePicker(context: context, initialTime: _timeSelesai);
//                 if (picked != null) setState(() => _timeSelesai = picked);
//               },
//             ),

//             const SizedBox(height: 30),

//             // Tombol Submit
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _submitBooking,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
//                 child: _isLoading 
//                   ? const CircularProgressIndicator(color: Colors.black)
//                   : const Text("Konfirmasi Booking", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }