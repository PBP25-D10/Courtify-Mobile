import 'package:flutter/material.dart';
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
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _jamBukaController = TextEditingController();
  final TextEditingController _jamTutupController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.lapangan != null) {
      _isEditing = true;
      _namaController.text = widget.lapangan!.nama;
      _deskripsiController.text = widget.lapangan!.deskripsi;
      _kategoriController.text = widget.lapangan!.kategori;
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
    _kategoriController.dispose();
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
      controller.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
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
              _buildTextField(_kategoriController, "Kategori", Icons.category),
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
              _buildTextField(_fotoController, "URL Foto (Opsional)", Icons.image),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
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
      validator: (v) => v!.isEmpty ? "$label tidak boleh kosong" : null,
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

    final payload = {
      'nama': _namaController.text,
      'deskripsi': _deskripsiController.text,
      'kategori': _kategoriController.text,
      'lokasi': _lokasiController.text,
      'harga_per_jam': int.parse(_hargaController.text),
      'jam_buka': _jamBukaController.text,
      'jam_tutup': _jamTutupController.text,
      'foto': _fotoController.text.isEmpty ? null : _fotoController.text,
      'penyedia_id': 1,
    };

    try {
      if (_isEditing) {
        await _api.updateLapangan(widget.lapangan!.idLapangan, payload);
      } else {
        await _api.createLapangan(payload);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? "Lapangan berhasil diupdate" : "Lapangan berhasil ditambahkan")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}