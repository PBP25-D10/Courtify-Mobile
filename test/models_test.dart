import 'package:courtify_mobile/module/booking/models/booking.dart';
import 'package:courtify_mobile/module/iklan/models/iklan.dart';
import 'package:courtify_mobile/module/lapangan/models/lapangan.dart';
import 'package:courtify_mobile/module/artikel/models/news.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lapangan model', () {
    test('parses json with fallback foto and time normalization', () {
      final lap = Lapangan.fromJson({
        'id_lapangan': '99',
        'nama': 'Lapangan A',
        'deskripsi': 'Desc',
        'kategori': 'futsal',
        'lokasi': 'Bandung',
        'harga_per_jam': '150000',
        'jam_buka': '07:00:00',
        'jam_tutup': '22:00:00',
      });

      expect(lap.idLapangan, '99');
      expect(lap.hargaPerJam, 150000);
      expect(lap.jamBuka, '07:00');
      expect(lap.jamTutup, '22:00');
      expect(lap.fotoUrl.isNotEmpty, isTrue); // fallback terisi
    });
  });

  group('Booking model', () {
    test('parses booking with nested lapangan', () {
      final booking = Booking.fromJson({
        'id': 1,
        'lapangan': {
          'id_lapangan': 'L1',
          'nama': 'Lap A',
          'deskripsi': 'Nice',
          'kategori': 'futsal',
          'lokasi': 'Jakarta',
          'harga_per_jam': 100000,
          'jam_buka': '06:00',
          'jam_tutup': '22:00',
          'url_thumbnail': 'http://example.com/a.jpg',
        },
        'tanggal': '2025-01-01',
        'jam_mulai': '10:00',
        'jam_selesai': '12:00',
        'total_harga': 200000,
        'status': 'pending',
        'created_at': '2024-12-01',
      });

      expect(booking.id, 1);
      expect(booking.lapangan?.nama, 'Lap A');
      expect(booking.status, 'pending');
      expect(booking.createdAt, '2024-12-01');
    });
  });

  group('Iklan model', () {
    test('parses iklan json', () {
      final iklan = Iklan.fromJson({
        'pk': 7,
        'judul': 'Promo',
        'deskripsi': 'Diskon',
        'banner': 'http://example.com/banner.jpg',
        'lapangan': '5',
        'tanggal': '2025-01-01',
      });

      expect(iklan.pk, 7);
      expect(iklan.banner, contains('http'));
      expect(iklan.lapanganId, '5');
    });
  });

  group('News model', () {
    test('parses news json with fallback thumbnail', () {
      final news = News.fromJson({
        'id': 3,
        'title': 'Judul',
        'content': 'Isi',
        'kategori': 'Futsal',
        'author': 'Admin',
        'created_at': '2025-01-01',
      });

      expect(news.id, 3);
      expect(news.thumbnailUrl.isNotEmpty, isTrue);
      expect(news.kategori, 'Futsal');
    });
  });
}
