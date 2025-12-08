import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pastikan add intl di pubspec.yaml atau gunakan manual format
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/module/booking/services/booking_api_service.dart';

class BookingCreateScreen extends StatefulWidget {
  final Lapangan lapangan;

  const BookingCreateScreen({super.key, required this.lapangan});

  @override
  State<BookingCreateScreen> createState() => _BookingCreateScreenState();
}

class _BookingCreateScreenState extends State<BookingCreateScreen> {
  final BookingApiService _apiService = BookingApiService();
  
  DateTime _selectedDate = DateTime.now();
  List<int> _bookedHours = [];
  int? _startHour;
  int? _endHour;
  bool _isLoadingHours = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchBookedHours();
  }

  // Ambil data jam yang sudah dibooking dari Django
  Future<void> _fetchBookedHours() async {
    setState(() {
      _isLoadingHours = true;
      _bookedHours = [];
      _startHour = null;
      _endHour = null;
    });

    final request = context.read<AuthService>();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      // Pastikan idLapangan dikonversi ke String jika perlu
      final booked = await _apiService.getBookedHours(
        request, 
        widget.lapangan.idLapangan.toString(), 
        dateStr
      );
      setState(() {
        _bookedHours = booked;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat jadwal: $e")),
      );
    } finally {
      setState(() {
        _isLoadingHours = false;
      });
    }
  }

  // Logic memilih jam
  void _handleTimeSelection(int hour) {
    if (_bookedHours.contains(hour)) return; // Jam sudah dibooking orang

    setState(() {
      if (_startHour == null || (_startHour != null && _endHour != null)) {
        // Reset selection (klik pertama)
        _startHour = hour;
        _endHour = null;
      } else {
        // Klik kedua (menentukan range)
        if (hour < _startHour!) {
          _startHour = hour; // User klik jam yang lebih awal
          _endHour = null;
        } else {
          // Cek apakah ada jam booked di antara start dan end
          bool blocked = false;
          for (int i = _startHour! + 1; i <= hour; i++) {
            if (_bookedHours.contains(i)) {
              blocked = true;
              break;
            }
          }

          if (blocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ada jam yang sudah terisi di rentang waktu ini.")),
            );
            _startHour = hour; // Reset ke single selection
            _endHour = null;
          } else {
            _endHour = hour; // Valid range
          }
        }
      }
    });
  }

  // Hitung Total Harga
  double _calculateTotalPrice() {
    if (_startHour == null) return 0;
    int duration = 1;
    if (_endHour != null) {
      duration = (_endHour! - _startHour!) + 1; // +1 karena inklusif jam terakhir
    }
    // Konversi int ke double/num untuk perhitungan
    return widget.lapangan.hargaPerJam.toDouble() * duration;
  }

  Future<void> _submitBooking() async {
    if (_startHour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih jam main terlebih dahulu")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final request = context.read<AuthService>();

    // Format jam untuk Django (HH:MM)
    // Jika user pilih jam 10, start = 10:00.
    // Jika user pilih range 10-12, start=10:00, selesai=13:00 (logika durasi)
    // TAPI, sesuaikan dengan logika modelmu. 
    // Biasanya kalau booking slot jam 10, artinya 10:00 - 11:00.
    // Kalau pilih 10 - 12, artinya 10:00 - 13:00 (3 jam).
    
    // Logic sederhana: Slot jam 10 = main 1 jam (10:00 - 11:00)
    int finalEndHour = (_endHour ?? _startHour)! + 1; 
    
    final payload = {
      'tanggal': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'jam_mulai': '${_startHour.toString().padLeft(2, '0')}:00',
      'jam_selesai': '${finalEndHour.toString().padLeft(2, '0')}:00',
    };

    try {
      await _apiService.createBooking(
        request, 
        widget.lapangan.idLapangan.toString(), 
        payload
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking Berhasil!"), backgroundColor: Colors.green),
      );
      
      // Kembali ke dashboard dengan refresh
      Navigator.pop(context, true); 

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan num agar support int/double
    num harga = widget.lapangan.hargaPerJam; 

    return Scaffold(
      appBar: AppBar(title: const Text("Booking Lapangan")),
      body: Column(
        children: [
          // Header Info Lapangan
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.lapangan.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Rp $harga / jam", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() => _selectedDate = picked);
                      _fetchBookedHours();
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // Grid Jam
          Expanded(
            child: _isLoadingHours 
              ? const Center(child: CircularProgressIndicator()) 
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Text("Pilih Jam Main:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, // 4 kolom
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: 24, // 00:00 - 23:00
                          itemBuilder: (context, index) {
                            final hour = index;
                            final isBooked = _bookedHours.contains(hour);
                            
                            // Logic warna seleksi
                            bool isSelected = false;
                            if (_startHour != null) {
                              if (_endHour == null) {
                                isSelected = (hour == _startHour);
                              } else {
                                isSelected = (hour >= _startHour! && hour <= _endHour!);
                              }
                            }

                            return InkWell(
                              onTap: isBooked ? null : () => _handleTimeSelection(hour),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isBooked 
                                      ? Colors.grey[300] // Booked
                                      : isSelected 
                                          ? Colors.green[600] // Selected
                                          : Colors.white, // Available
                                  border: Border.all(
                                    color: isSelected ? Colors.green : Colors.grey.shade300
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${hour.toString().padLeft(2, '0')}:00",
                                  style: TextStyle(
                                    color: isBooked ? Colors.grey : (isSelected ? Colors.white : Colors.black87),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),

          // Footer Total Harga & Submit
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Total Harga:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          "Rp ${_calculateTotalPrice().toStringAsFixed(0)}", 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: _isSubmitting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Booking Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}