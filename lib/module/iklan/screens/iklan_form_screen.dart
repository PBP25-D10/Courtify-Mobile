import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // [PERBAIKAN 1] Import ini untuk deteksi Web
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/iklan/services/iklan_api_services.dart';
import 'package:courtify_mobile/module/lapangan/services/api_services.dart';
import 'package:courtify_mobile/module/iklan/models/iklan.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:image_picker/image_picker.dart';

class IklanFormScreen extends StatefulWidget {
  final Iklan? iklan; // Jika null = Buat Baru, Jika ada = Edit
  final List<Lapangan>? lapangan;

  const IklanFormScreen({super.key, this.iklan, this.lapangan});

  @override
  State<IklanFormScreen> createState() => _IklanFormScreenState();
}

class _IklanFormScreenState extends State<IklanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final IklanApiService _iklanApi = IklanApiService();
  final LapanganApiService _lapanganApi = LapanganApiService();

  // Controllers
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  // State Variables
  bool _isLoading = false;
  List<Lapangan> _lapanganList = [];
  String? _selectedLapanganId;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchLapangan();

    // Jika mode Edit, isi form dengan data yang ada
    if (widget.iklan != null) {
      _judulController.text = widget.iklan!.judul;
      _deskripsiController.text = widget.iklan!.deskripsi;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // ============================
  // FETCH DATA LAPANGAN
  // ============================
  Future<void> _fetchLapangan() async {
    final request = context.read<AuthService>();
    try {
      final list = await _lapanganApi.getPenyediaLapangan(request);
      setState(() {
        _lapanganList = list;

        if (widget.iklan != null) {
          _selectedLapanganId = widget.iklan!.lapangan.toString();

          bool exists = _lapanganList.any((l) => l.idLapangan.toString() == _selectedLapanganId);
          if (!exists) _selectedLapanganId = null;
        }
      });
    } catch (e) {
      print("Error fetching lapangan: $e");
    }
  }

  // ============================
  // PICK IMAGE
  // ============================
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // ============================
  // SUBMIT FORM
  // ============================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = context.read<AuthService>();
    final isEdit = widget.iklan != null;

    Map<String, dynamic> payload = {
      'judul': _judulController.text,
      'deskripsi': _deskripsiController.text,
      'lapangan': _selectedLapanganId,
    };

    if (_selectedImage != null) {
      List<int> imageBytes = await _selectedImage!.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      payload['banner'] = base64Image;
    }

    try {
      Map<String, dynamic> response;
      if (isEdit) {
        response = await _iklanApi.updateIklan(request, widget.iklan!.pk, payload);
      } else {
        response = await _iklanApi.createIklan(request, payload);
      }

      setState(() => _isLoading = false);

      if (response['status'] == 'success' || response['success'] == true) {
        if (mounted) _showSuccessDialog(isEdit);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal menyimpan data")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  // ============================
  // MODAL SUKSES (Pop Up)
  // ============================
  void _showSuccessDialog(bool isEdit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Berhasil!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEdit
                      ? "Perubahan berhasil disimpan."
                      : "Iklan berhasil dibuat.",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25EB7B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    child: const Text(
                      "Ok",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================
  // UI BUILDER
  // ============================
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.iklan != null;

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Iklan" : "Buat Iklan",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF111827),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. JUDUL
              _buildLabel("Judul"),
              TextFormField(
                controller: _judulController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Masukkan judul iklan"),
                validator: (val) => val!.isEmpty ? "Judul tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // 2. DESKRIPSI
              _buildLabel("Deskripsi"),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Masukkan deskripsi iklan"),
                validator: (val) => val!.isEmpty ? "Deskripsi tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // 3. DROPDOWN LAPANGAN
              _buildLabel("Lapangan"),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(""),
                hint: const Text("-- Pilih Lapangan --", style: TextStyle(color: Colors.grey)),
                value: _selectedLapanganId,
                items: _lapanganList.map((lap) {
                  return DropdownMenuItem(
                    value: lap.idLapangan.toString(),
                    child: Text(
                      lap.nama,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedLapanganId = val;
                  });
                },
                validator: (val) => val == null ? "Pilih lapangan" : null,
              ),
              const SizedBox(height: 16),

              // 4. BANNER (Image Picker)
              _buildLabel("Banner"),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2563EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (_selectedImage != null) ...[
                        // --- [PERBAIKAN 3] Logika Preview Gambar Web vs HP ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImage!.path, // Kalau Web pakai network/blob URL
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedImage!.path), // Kalau HP pakai File
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedImage!.name,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.edit, color: Colors.white, size: 20),
                      ] else ...[
                        // --- Tampilan jika belum ada gambar ---
                        const Icon(Icons.image, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          "No image chosen",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 5. TOMBOL AKSI (Batal & Simpan)
              Row(
                children: [
                  // Tombol Batal
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B7280),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Batal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Tombol Simpan
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Simpan Iklan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // HELPER WIDGETS
  // ============================
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
    );
  }
}