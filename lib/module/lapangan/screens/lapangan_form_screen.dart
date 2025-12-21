import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/lapangan/services/api_services.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/theme/app_colors.dart';

class LapanganFormScreen extends StatefulWidget {
  final Lapangan? lapangan;
  const LapanganFormScreen({super.key, this.lapangan});

  @override
  State<LapanganFormScreen> createState() => _LapanganFormScreenState();
}

class _LapanganFormScreenState extends State<LapanganFormScreen> {
  static const Color _backgroundColor = AppColors.background;
  static const Color _cardColor = AppColors.card;
  static const Color _accent = AppColors.primary;

  final _formKey = GlobalKey<FormState>();
  final LapanganApiService _api = LapanganApiService();

  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _jamBukaController = TextEditingController();
  final _jamTutupController = TextEditingController();
  final _thumbnailController = TextEditingController();

  String? _selectedKategori;
  bool _isEditing = false;

  String _normTime(String s) => s.length >= 5 ? s.substring(0, 5) : s;

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
      _jamBukaController.text = _normTime(widget.lapangan!.jamBuka);
      _jamTutupController.text = _normTime(widget.lapangan!.jamTutup);
      _thumbnailController.text = widget.lapangan!.fotoUrl;
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
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;
    final adjusted = TimeOfDay(hour: picked.hour, minute: 0);
    controller.text =
        "${adjusted.hour.toString().padLeft(2, '0')}:${adjusted.minute.toString().padLeft(2, '0')}";
  }

  int _hour(String hhmm) => int.parse(_normTime(hhmm).split(':')[0]);
  int _minute(String hhmm) => int.parse(_normTime(hhmm).split(':')[1]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Lapangan" : "Tambah Lapangan",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField(_namaController, "Nama Lapangan", Icons.sports_soccer),
                const SizedBox(height: 16),
                _buildTextField(_deskripsiController, "Deskripsi", Icons.description, maxLines: 3),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedKategori,
                  decoration: _inputDecoration("Kategori", icon: Icons.category),
                  dropdownColor: _cardColor,
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'futsal', child: Text('Futsal')),
                    DropdownMenuItem(value: 'basket', child: Text('Basket')),
                    DropdownMenuItem(value: 'badminton', child: Text('Badminton')),
                    DropdownMenuItem(value: 'tenis', child: Text('Tenis')),
                    DropdownMenuItem(value: 'voli', child: Text('Voli')),
                    DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
                  ],
                  onChanged: (v) => setState(() => _selectedKategori = v),
                  validator: (v) => v == null ? "Kategori tidak boleh kosong" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(_lokasiController, "Lokasi", Icons.location_on),
                const SizedBox(height: 16),
                _buildTextField(_hargaController, "Harga Per Jam", Icons.attach_money, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField(_thumbnailController, "URL Thumbnail (opsional)", Icons.image, isRequired: false),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTimeField(_jamBukaController, "Jam Buka")),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimeField(_jamTutupController, "Jam Tutup")),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isEditing ? "Update" : "Simpan",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon: icon),
      style: const TextStyle(color: Colors.white),
      validator: isRequired ? (v) => (v == null || v.isEmpty) ? "$label tidak boleh kosong" : null : null,
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: icon != null ? Icon(icon, color: _accent) : null,
      filled: true,
      fillColor: Colors.black26,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white70),
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: _inputDecoration(label, icon: Icons.access_time),
      style: const TextStyle(color: Colors.white),
      validator: (v) => (v == null || v.isEmpty) ? "$label tidak boleh kosong" : null,
      onTap: () => _selectTime(context, controller),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // validate minimal 1 jam
    final buka = DateTime(2023, 1, 1, _hour(_jamBukaController.text), _minute(_jamBukaController.text));
    final tutup = DateTime(2023, 1, 1, _hour(_jamTutupController.text), _minute(_jamTutupController.text));
    if (tutup.isBefore(buka.add(const Duration(hours: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jam tutup harus minimal 1 jam setelah jam buka")),
      );
      return;
    }

    final harga = int.tryParse(_hargaController.text);
    if (harga == null || harga <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harga per jam harus berupa angka lebih dari 0")),
      );
      return;
    }

    final request = context.read<AuthService>();

    final payload = {
      'nama': _namaController.text,
      'deskripsi': _deskripsiController.text,
      'kategori': _selectedKategori ?? '',
      'lokasi': _lokasiController.text,
      'harga_per_jam': harga,
      'jam_buka': _normTime(_jamBukaController.text),
      'jam_tutup': _normTime(_jamTutupController.text),
      // jangan kirim "foto" di payload JSON; upload lewat multipart
    };

    if (_thumbnailController.text.isNotEmpty) {
      payload['url_thumbnail'] = _thumbnailController.text.trim();
    }

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
          SnackBar(content: Text(response['message']?.toString() ?? "Terjadi kesalahan")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
