import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ArticleFormPage extends StatefulWidget {
  const ArticleFormPage({super.key});

  @override
  State<ArticleFormPage> createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _content = "";
  String _kategori = "Komunitas";

  final List<String> _kategoriList = [
    'Futsal',
    'Basket',
    'Badminton',
    'Tenis',
    'Padel',
    'Komunitas',
    'Tips',
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Artikel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Judul
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Judul",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _title = v,
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Judul tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // Konten
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Konten",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                onChanged: (v) => _content = v,
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Konten tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(),
                ),
                value: _kategori,
                items: _kategoriList
                    .map((k) => DropdownMenuItem(
                          value: k,
                          child: Text(k),
                        ))
                    .toList(),
                onChanged: (v) => _kategori = v ?? "Komunitas",
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // B6: logic POST ke Django (lihat di bawah)
                    final baseUrl = "http://localhost:8000";
                    final response = await request.postJson(
                      "$baseUrl/artikel/create-flutter/",
                      jsonEncode({
                        "title": _title,
                        "content": _content,
                        "kategori": _kategori,
                      }),
                    );

                    if (context.mounted) {
                      if (response['status'] == "success") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Artikel berhasil disimpan."),
                          ),
                        );
                        Navigator.pop(context); // kembali ke list
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Gagal menyimpan artikel: ${response['message'] ?? ''}"),
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}