import 'dart:convert';

import 'package:courtify_mobile/module/wishlist/models/wishlist_item.dart';
import 'package:courtify_mobile/module/wishlist/services/wishlist_api_service.dart';
import 'package:courtify_mobile/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

class _MockAuthService extends Mock implements AuthService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('AuthService (local storage)', () {
    late AuthService auth;

    setUp(() {
      auth = AuthService();
      SharedPreferences.setMockInitialValues({});
    });

    test('isLoggedIn true when sessionid exists', () async {
      SharedPreferences.setMockInitialValues({
        'all_cookies': jsonEncode({'sessionid': 'abc123'})
      });

      expect(await auth.isLoggedIn(), isTrue);
    });

    test('getCookiesHeader builds cookie string', () async {
      SharedPreferences.setMockInitialValues({
        'all_cookies': jsonEncode({'sessionid': 'abc123', 'other': 'x'}),
      });

      final cookie = await auth.getCookiesHeader();
      expect(cookie, contains('sessionid=abc123'));
      expect(cookie, contains('other=x'));
    });

    test('getJsonData returns stored username and role', () async {
      SharedPreferences.setMockInitialValues({
        'user_role': 'penyedia',
        'user_username': 'jane',
      });

      final data = await auth.getJsonData();
      expect(data['username'], 'jane');
      expect(data['role'], 'penyedia');
    });
  });

  group('AuthService (network)', () {
    test('login stores cookies, role, username', () async {
      SharedPreferences.setMockInitialValues({});
      final client = MockClient((request) async {
        expect(request.url.toString(), contains('/login/'));
        return http.Response(
          jsonEncode({
            'status': true,
            'sessionid': 'sess123',
            'user': {'role': 'user', 'username': 'jane'}
          }),
          200,
          headers: {'set-cookie': 'sessionid=sess123; Path=/'},
        );
      });

      final auth = AuthService(clientFactory: () => client);
      final res = await auth.login('jane', 'pass');

      expect(res['status'], true);
      expect(res['role'], 'user');
      expect(res['username'], 'jane');
      final cookies = await auth.getCookiesHeader();
      expect(cookies, contains('sessionid=sess123'));
      expect(await auth.getCurrentRole(), 'user');
      expect(await auth.getCurrentUsername(), 'jane');
    });

    test('logout clears prefs even when server reachable', () async {
      SharedPreferences.setMockInitialValues({
        'user_username': 'jane',
        'user_role': 'user',
        'all_cookies': jsonEncode({'sessionid': 'abc'})
      });

      final client = MockClient((request) async {
        expect(request.url.toString(), contains('/logout/'));
        return http.Response(jsonEncode({'status': true}), 200);
      });
      final auth = AuthService(clientFactory: () => client);
      await auth.logout();
      expect(await auth.isLoggedIn(), isFalse);
      expect(await auth.getCurrentUsername(), isNull);
    });

    test('register success stores role and username', () async {
      SharedPreferences.setMockInitialValues({});
      final client = MockClient((request) async {
        expect(request.url.toString(), contains('/register/'));
        return http.Response(
          jsonEncode({
            'status': true,
            'user': {'username': 'alice', 'role': 'penyedia'}
          }),
          201,
        );
      });
      final auth = AuthService(clientFactory: () => client);
      final res = await auth.register(
        username: 'alice',
        email: 'a@b.com',
        password: 'pass',
        role: 'penyedia',
      );
      expect(res['status'], true);
      expect(await auth.getCurrentRole(), 'penyedia');
      expect(await auth.getCurrentUsername(), 'alice');
    });

    test('fetchCurrentSession stores role/username from /me', () async {
      SharedPreferences.setMockInitialValues({});
      final client = MockClient((request) async {
        expect(request.url.toString(), contains('/me/'));
        return http.Response(
          jsonEncode({
            'user': {'username': 'bob', 'role': 'user'}
          }),
          200,
        );
      });
      final auth = AuthService(clientFactory: () => client);
      final res = await auth.fetchCurrentSession();
      expect(res['user']['username'], 'bob');
      expect(await auth.getCurrentUsername(), 'bob');
      expect(await auth.getCurrentRole(), 'user');
    });
  });

  group('WishlistApiService', () {
    late _MockAuthService mockAuth;
    late WishlistApiService service;

    setUp(() {
      mockAuth = _MockAuthService();
      service = WishlistApiService();
    });

    test('fetchWishlist parses list correctly', () async {
      when(() => mockAuth.get(any(), requireAuth: any(named: 'requireAuth')))
          .thenAnswer((_) async => {
                'status': 'success',
                'wishlist': [
                  {
                    'id': 1,
                    'lapangan': {
                      'id_lapangan': 'A1',
                      'nama': 'Lapangan A',
                      'deskripsi': 'desc',
                      'kategori': 'futsal',
                      'lokasi': 'Jakarta',
                      'harga_per_jam': 100000,
                      'foto': 'http://example.com/foto.jpg',
                      'jam_buka': '07:00',
                      'jam_tutup': '21:00',
                    },
                    'created_at': '2025-01-01',
                  }
                ]
              });

      final result = await service.fetchWishlist(mockAuth);
      expect(result, hasLength(1));
      expect(result.first, isA<WishlistItem>());
      expect(result.first.lapangan.nama, 'Lapangan A');
    });

    test('toggle returns added flag', () async {
      when(() => mockAuth.postJson(any(), any(),
              requireAuth: any(named: 'requireAuth')))
          .thenAnswer((_) async => {'status': 'success', 'added': true});

      final added = await service.toggle(mockAuth, 'A1');
      expect(added, isTrue);
    });

    test('deleteById completes when success', () async {
      when(() => mockAuth.postJson(any(), any(),
              requireAuth: any(named: 'requireAuth')))
          .thenAnswer((_) async => {'status': 'success'});

      await service.deleteById(mockAuth, 1);
      verify(() => mockAuth.postJson(any(), any(),
          requireAuth: any(named: 'requireAuth'))).called(1);
    });

    test('check returns in_wishlist flag', () async {
      when(() => mockAuth.get(any(), requireAuth: any(named: 'requireAuth')))
          .thenAnswer((_) async => {'status': 'success', 'in_wishlist': true});

      final exists = await service.check(mockAuth, 'A1');
      expect(exists, isTrue);
    });
  });
}
