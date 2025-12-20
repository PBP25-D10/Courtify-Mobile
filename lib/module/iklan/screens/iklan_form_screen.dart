import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/iklan/services/iklan_api_services.dart';
import 'package:courtify_mobile/module/lapangan/services/api_services.dart';
import 'package:courtify_mobile/module/iklan/models/iklan.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';

class IklanFormScreen extends StatefulWidget {
  final Iklan? iklan; 
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
      if (!mounted) return;
      
      setState(() {
        _lapanganList = list;

        if (widget.iklan != null) {
          _selectedLapanganId = widget.iklan!.lapanganId; 

          // Validasi apakah lapangan ID lama masih ada di list
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
    if (!_formKey.currentState!.validate()) {};

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
      
      payload['banner'] = "data:image/jpeg;base64,$base64Image";
    }

    try {
      Map<String, dynamic> response;
      if (isEdit) {
        response = await _iklanApi.updateIklan(request, widget.iklan!.pk.toString(), payload);
      } else {
        response = await _iklanApi.createIklan(request, payload);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response['status'] == 'success' || response['success'] == true) {
        _showSuccessDialog(isEdit);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal menyimpan data")),
        );
      }
    } catch (e) {
      if (!mounted) return;
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
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, 
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
  // HELPER UI BUILDER
  // ============================
   
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent)
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (val) => val!.isEmpty ? "$label tidak boleh kosong" : null,
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
          style: const TextStyle(color: Colors.white),
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
              _buildTextField(_judulController, "Judul Iklan"),
              const SizedBox(height: 16),

              // 2. DESKRIPSI
              _buildTextField(_deskripsiController, "Deskripsi Iklan", maxLines: 4),
              const SizedBox(height: 16),

              // 3. DROPDOWN LAPANGAN
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF374151),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Pilih Lapangan",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF374151),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), 
                    borderSide: BorderSide.none
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent)
                  ),
                ),
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

              // 4. BANNER (Image Picker dengan Logic Preview Gambar Lama)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF374151),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        // KONDISI 1: User baru saja memilih gambar baru dari galeri
                        if (_selectedImage != null) ...[
                         ClipRRect(
                           borderRadius: BorderRadius.circular(4),
                           child: kIsWeb
                               ? Image.network(
                                   _selectedImage!.path, 
                                   width: 30,
                                   height: 30,
                                   fit: BoxFit.cover,
                                 )
                               : Image.file(
                                   File(_selectedImage!.path), 
                                   width: 30,
                                   height: 30,
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
                         const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                        ] 
                        // KONDISI 2: Mode Edit & User belum pilih gambar baru, tapi ada gambar lama
                        else if (isEdit && widget.iklan?.banner != null && widget.iklan!.banner!.isNotEmpty) ...[
                          ClipRRect(
                           borderRadius: BorderRadius.circular(4),
                           child: Image.network(
                               widget.iklan!.banner!, 
                               width: 30,
                               height: 30,
                               fit: BoxFit.cover,
                               errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                             ),
                         ),
                         const SizedBox(width: 12),
                         const Expanded(
                           child: Text(
                             "Ganti Banner (Saat ini terpasang)",
                             style: TextStyle(color: Colors.white),
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                         const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                        ]
                        // KONDISI 3: Belum ada gambar sama sekali
                        else ...[
                          const Text(
                            "Pilih Banner (Opsional)",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.image, color: Colors.white, size: 20),
                        ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 5. TOMBOL AKSI
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.grey)
                          ),
                        ),
                        child: const Text("Batal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
}