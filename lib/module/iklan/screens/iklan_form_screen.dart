import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:courtify_mobile/module/iklan/services/iklan_api_services.dart';
import 'package:courtify_mobile/module/lapangan/services/api_services.dart';
import 'package:courtify_mobile/module/iklan/models/iklan.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/theme/app_colors.dart';

class IklanFormScreen extends StatefulWidget {
  final Iklan? iklan; 
  final List<Lapangan>? lapangan;

  const IklanFormScreen({super.key, this.iklan, this.lapangan});

  @override
  State<IklanFormScreen> createState() => _IklanFormScreenState();
}

class _IklanFormScreenState extends State<IklanFormScreen> {
  static const Color _backgroundColor = AppColors.background;
  static const Color _cardColor = AppColors.card;
  static const Color _accentColor = AppColors.primary;

  final _formKey = GlobalKey<FormState>();
  final IklanApiService _iklanApi = IklanApiService();
  final LapanganApiService _lapanganApi = LapanganApiService();

  // Controllers
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _urlThumbnailController = TextEditingController();

  // State Variables
  bool _isLoading = false;
  List<Lapangan> _lapanganList = [];
  String? _selectedLapanganId;

  @override
  void initState() {
    super.initState();
    _fetchLapangan();

    if (widget.iklan != null) {
      _judulController.text = widget.iklan!.judul;
      _deskripsiController.text = widget.iklan!.deskripsi;
      _urlThumbnailController.text = widget.iklan!.banner;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _urlThumbnailController.dispose();
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

    if (_urlThumbnailController.text.isNotEmpty) {
      payload['url_thumbnail'] = _urlThumbnailController.text.trim();
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
      decoration: _inputDecoration(label),
      style: const TextStyle(color: Colors.white),
      validator: (val) => val!.isEmpty ? "$label tidak boleh kosong" : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.black26,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
      ),
    );
  }

  // ============================
  // UI BUILDER
  // ============================
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.iklan != null;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Iklan" : "Buat Iklan",
          style: const TextStyle(color: Colors.white),
        ),
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
                _buildTextField(_judulController, "Judul Iklan"),
                const SizedBox(height: 16),
                _buildTextField(_deskripsiController, "Deskripsi Iklan", maxLines: 4),
                const SizedBox(height: 16),
                _buildTextField(_urlThumbnailController, "URL Thumbnail (opsional)"),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  dropdownColor: _cardColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Pilih Lapangan"),
                  value: _selectedLapanganId,
                  items: _lapanganList.map((lap) {
                    return DropdownMenuItem(
                      value: lap.idLapangan.toString(),
                      child: Text(
                        lap.nama,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Simpan",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
