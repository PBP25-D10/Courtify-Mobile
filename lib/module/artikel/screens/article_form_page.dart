import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/artikel/models/news.dart';
import 'package:courtify_mobile/module/artikel/services/news_service.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';

class ArticleFormPage extends StatefulWidget {
  final News? news;
  const ArticleFormPage({super.key, this.news});

  @override
  State<ArticleFormPage> createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _kategori = 'Komunitas';

  static const Color backgroundColor = Color(0xFF111827);
  static const Color cardColor = Color(0xFF1F2937);
  static const Color accent = Color(0xFF2563EB);

  final List<String> _kategoriList = const [
    'Futsal',
    'Basket',
    'Badminton',
    'Tenis',
    'Padel',
    'Komunitas',
    'Tips',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.news != null) {
      _titleController.text = widget.news!.title;
      _contentController.text = widget.news!.content;
      _kategori = widget.news!.kategori.isNotEmpty ? widget.news!.kategori : 'Komunitas';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final service = NewsApiService();

    try {
      if (widget.news == null) {
        await service.createNews(auth, {
          'title': _titleController.text,
          'content': _contentController.text,
          'kategori': _kategori,
        });
      } else {
        await service.updateNews(auth, widget.news!.id, {
          'title': _titleController.text,
          'content': _contentController.text,
          'kategori': _kategori,
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikel berhasil disimpan'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan artikel: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Tambah Artikel', style: TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('Judul'),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => (v == null || v.isEmpty) ? 'Judul tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: _inputDecoration('Konten'),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  validator: (v) => (v == null || v.isEmpty) ? 'Konten tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _kategori,
                  dropdownColor: cardColor,
                  decoration: _inputDecoration('Kategori'),
                  items: _kategoriList
                      .map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (v) => setState(() => _kategori = v ?? 'Komunitas'),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: accent, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        borderSide: const BorderSide(color: Colors.white70),
      ),
    );
  }
}
