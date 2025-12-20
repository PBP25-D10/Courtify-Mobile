import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/artikel/screens/news_list_page.dart';

class ArtikelPenyediaScreen extends StatelessWidget {
  const ArtikelPenyediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NewsListPage(isProvider: true);
  }
}
