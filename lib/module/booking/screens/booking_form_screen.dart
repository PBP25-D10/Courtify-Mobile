import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/booking/services/api_services_booking.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class BookingFormScreen extends StatefulWidget {
  final Lapangan lapangan;

  const BookingFormScreen({super.key, required this.lapangan});
  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingApiService _api = BookingApiService();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  // ============================
  // PICK DATE
  // ============================
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _dateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  // ============================
  // PICK TIME
  // ============================
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      controller.text =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  // ============================
  // SUBMIT BOOKING
  // ============================
  


  // ============================
  // BUILD UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: Text(
          "Booking ${widget.lapangan.nama}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF111827),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===========================
              // CARD INFO LAPANGAN
              // ===========================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports_soccer,
                        color: Colors.blueAccent, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.lapangan.nama,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text(widget.lapangan.kategori,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Isi Data Booking",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // ===========================
              // DATE
              // ===========================
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration:
                    _inputDecoration("Tanggal Main", Icons.calendar_today),
                style: const TextStyle(color: Colors.white),
                validator: (v) =>
                    v!.isEmpty ? "Tanggal tidak boleh kosong" : null,
                onTap: () => _selectDate(context),
              ),

              const SizedBox(height: 16),

              // ===========================
              // TIME START & END
              // ===========================
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      readOnly: true,
                      decoration:
                          _inputDecoration("Jam Mulai", Icons.access_time),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => v!.isEmpty ? "Isi jam mulai" : null,
                      onTap: () => _selectTime(context, _startTimeController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      readOnly: true,
                      decoration: _inputDecoration(
                          "Jam Selesai", Icons.access_time_filled),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => v!.isEmpty ? "Isi jam selesai" : null,
                      onTap: () => _selectTime(context, _endTimeController),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ===========================
              // BUTTON BOOKING
              // ===========================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    if (_startTimeController.text
                            .compareTo(_endTimeController.text) >=
                        0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Jam selesai harus lebih besar dari jam mulai.")),
                      );
                      return;
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Konfirmasi Booking",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // DECORATION INPUT
  // ============================
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: const Color(0xFF374151),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent),
      ),
    );
  }
}
