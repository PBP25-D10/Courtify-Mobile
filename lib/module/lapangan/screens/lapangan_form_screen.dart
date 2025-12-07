import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/lapangan/services/api_services.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class LapanganFormScreen extends StatefulWidget {
  final Lapangan? lapangan;

  const LapanganFormScreen({super.key, this.lapangan});

  @override
  State<LapanganFormScreen> createState() => _LapanganFormScreenState();
}

class _LapanganFormScreenState extends State<LapanganFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final LapanganApiService _api = LapanganApiService();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _jamBukaController = TextEditingController();
  final TextEditingController _jamTutupController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();

  String? _selectedKategori;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.lapangan != null) {
      _isEditing = true;
      _namaController.text = widget.lapangan!.nama;
      _deskripsiController.text = widget.lapangan!.deskripsi;
      _selectedKategori = widget.lapangan!.kategori;
      _lokasiController.text = widget.lapangan!.lokasi;
      _hargaController.text = widget.lapangan!.hargaPerJam.toString();
      _jamBukaController.text = widget.lapangan!.jamBuka;
      _jamTutupController.text = widget.lapangan!.jamTutup;
      _fotoController.text = widget.lapangan!.fotoUrl ?? '';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _hargaController.dispose();
    _jamBukaController.dispose();
    _jamTutupController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      // Force minute to 0
      final adjusted = TimeOfDay(hour: picked.hour, minute: 0);
      controller.text = "${adjusted.hour.toString().padLeft(2, '0')}:${adjusted.minute.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: Text(
          _isEditing ? "Edit Lapangan" : "Tambah Lapangan",
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
              _buildTextField(_namaController, "Nama Lapangan", Icons.sports_soccer),
              const SizedBox(height: 16),
              _buildTextField(_deskripsiController, "Deskripsi", Icons.description, maxLines: 3),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                decoration: InputDecoration(
                  labelText: "Kategori",
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.category, color: Colors.blueAccent),
                  filled: true,
                  fillColor: const Color(0xFF374151),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                dropdownColor: const Color(0xFF374151),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'futsal', child: Text('Futsal')),
                  DropdownMenuItem(value: 'basket', child: Text('Basket')),
                  DropdownMenuItem(value: 'badminton', child: Text('Badminton')),
                  DropdownMenuItem(value: 'tenis', child: Text('Tenis')),
                  DropdownMenuItem(value: 'voli', child: Text('Voli')),
                  DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = value;
                  });
                },
                validator: (value) => value == null ? "Kategori tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(_lokasiController, "Lokasi", Icons.location_on),
              const SizedBox(height: 16),
              _buildTextField(_hargaController, "Harga Per Jam", Icons.attach_money, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(_jamBukaController, "Jam Buka"),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(_jamTutupController, "Jam Tutup"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_fotoController, "URL Foto (Opsional)", Icons.image, isRequired: false),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? "Update" : "Simpan",
                    style: const TextStyle(
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
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
      ),
      style: const TextStyle(color: Colors.white),
      validator: isRequired ? (v) => v!.isEmpty ? "$label tidak boleh kosong" : null : null,
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.access_time, color: Colors.blueAccent),
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (v) => v!.isEmpty ? "$label tidak boleh kosong" : null,
      onTap: () => _selectTime(context, controller),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate time difference
    final bukaParts = _jamBukaController.text.split(':');
    final tutupParts = _jamTutupController.text.split(':');
    final bukaHour = int.parse(bukaParts[0]);
    final tutupHour = int.parse(tutupParts[0]);
    final bukaMinute = int.parse(bukaParts[1]);
    final tutupMinute = int.parse(tutupParts[1]);

    final bukaTime = DateTime(2023, 1, 1, bukaHour, bukaMinute);
    final tutupTime = DateTime(2023, 1, 1, tutupHour, tutupMinute);

    if (tutupTime.isBefore(bukaTime.add(const Duration(hours: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jam tutup harus minimal 1 jam setelah jam buka")),
      );
      return;
    }

    final request = context.read<AuthService>();

    final payload = {
      'nama': _namaController.text,
      'deskripsi': _deskripsiController.text,
      'kategori': _selectedKategori,
      'lokasi': _lokasiController.text,
      'harga_per_jam': int.parse(_hargaController.text),
      'jam_buka': _jamBukaController.text,
      'jam_tutup': _jamTutupController.text,
      
    };

    try {
      Map<String, dynamic> response;
      
      if (_isEditing) {
        response = await _api.updateLapangan(request, widget.lapangan!.idLapangan, payload);
      } else {
        response = await _api.createLapangan(request, payload);
      }

      if (!mounted) return;

      if (response['status'] == 'success') {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? "Lapangan berhasil diupdate" : "Lapangan berhasil ditambahkan")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Terjadi kesalahan")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}