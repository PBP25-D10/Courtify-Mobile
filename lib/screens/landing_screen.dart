import 'package:flutter/material.dart';
import 'package:courtify_mobile/screens/login_screen.dart';
import 'package:courtify_mobile/screens/register_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  static const Color _background = Color(0xFF0B1424);
  static const Color _card = Color(0xFF0F1F35);
  static const Color _accent = Color(0xFF2563EB);
  void _openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
  void _openRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1222),
              Color(0xFF0D1B32),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHero(context),
                const SizedBox(height: 26),
                _buildSection(
                  context,
                  imagePath: 'assets/images/asset1_lapangan.png',
                  titleTop: 'BE PART',
                  titleBottom: 'OF THE GAME',
                  description:
                      'Pesan lapangan olahraga terbaik dengan mudah dan cepat. Nikmati pengalaman booking yang seamless untuk semua kebutuhan olahraga Anda.',
                  buttonLabel: 'Lihat Lapangan',
                  onPressed: () => _openLogin(context),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  context,
                  imagePath: 'assets/images/asset2_artikel.png',
                  titleTop: 'STAY',
                  titleBottom: 'INFORMED',
                  description:
                      'Baca artikel dan berita terkini tentang dunia olahraga. Dapatkan tips, trik, dan informasi menarik dari para ahli.',
                  buttonLabel: 'Baca Artikel',
                  onPressed: () => _openLogin(context),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    '(c) 2025 Courtify. All rights reserved.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
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
  Widget _buildHero(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 520,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/asset3_hero.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 520,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.65),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Courtify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _openLogin(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      FilledButton(
                        onPressed: () => _openRegister(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Selamat Datang\ndi ',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'Courtify',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: _accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Platform pemesanan lapangan olahraga terbaik untuk semua kebutuhanmu.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 26),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () => _openLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _openRegister(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.6)),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildSection(
    BuildContext context, {
    required String imagePath,
    required String titleTop,
    required String titleBottom,
    required String description,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              titleTop,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              titleBottom,
              style: TextStyle(
                color: _accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.78),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
