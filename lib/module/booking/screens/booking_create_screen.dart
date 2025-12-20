import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  static const Color backgroundColor = Color(0xFF111827);
  static const Color cardColor = Color(0xFF1F2937);
  static const Color accent = Color(0xFF2563EB);

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
      final booked = await _apiService.getBookedHours(
        request,
        widget.lapangan.idLapangan.toString(),
        dateStr,
      );
      if (!mounted) return;
      setState(() {
        _bookedHours = booked;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat jadwal: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHours = false;
        });
      }
    }
  }

  void _handleTimeSelection(int hour) {
    if (_bookedHours.contains(hour)) return;

    setState(() {
      if (_startHour == null || (_startHour != null && _endHour != null)) {
        _startHour = hour;
        _endHour = null;
      } else {
        if (hour < _startHour!) {
          _startHour = hour;
          _endHour = null;
        } else {
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
            _startHour = hour;
            _endHour = null;
          } else {
            _endHour = hour;
          }
        }
      }
    });
  }

  double _calculateTotalPrice() {
    if (_startHour == null) return 0;
    int duration = 1;
    if (_endHour != null) {
      duration = (_endHour! - _startHour!) + 1;
    }
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
        payload,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking Berhasil!"), backgroundColor: Colors.green),
      );

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
    num harga = widget.lapangan.hargaPerJam;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Booking Lapangan", style: TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: cardColor,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.lapangan.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("Rp $harga / jam", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w600)),
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
                      if (!mounted) return;
                      setState(() => _selectedDate = picked);
                      _fetchBookedHours();
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                  style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white12),

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
                          child: Text("Pilih Jam Main:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: 24,
                            itemBuilder: (context, index) {
                              final hour = index;
                              final isBooked = _bookedHours.contains(hour);

                              bool isSelected = false;
                              if (_startHour != null) {
                                if (_endHour == null) {
                                  isSelected = (hour == _startHour);
                                } else {
                                  isSelected = (hour >= _startHour! && hour <= _endHour!);
                                }
                              }

                              Color tileColor;
                              if (isBooked) {
                                tileColor = Colors.grey.shade800;
                              } else if (isSelected) {
                                tileColor = accent;
                              } else {
                                tileColor = cardColor;
                              }

                              return InkWell(
                                onTap: isBooked ? null : () => _handleTimeSelection(hour),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: tileColor,
                                    border: Border.all(
                                      color: isSelected ? Colors.white : Colors.white12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${hour.toString().padLeft(2, '0')}:00",
                                    style: TextStyle(
                                      color: isBooked
                                          ? Colors.grey
                                          : (isSelected ? Colors.white : Colors.white70),
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

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Total Harga:", style: TextStyle(fontSize: 12, color: Colors.white70)),
                        Text(
                          "Rp ${_calculateTotalPrice().toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
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
