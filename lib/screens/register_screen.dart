import 'package:flutter/material.dart';
import 'package:courtify_mobile/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color backgroundColor = Color(0xFF0F1624);
  static const Color cardColor = Color(0xFF1F2937);
  static const Color accent = Color(0xFF2563EB);
  // Controllers untuk text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // Instance AuthService
  final AuthService _authService = AuthService();

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  // Variabel untuk menyimpan role yang dipilih ('user' atau 'penyedia')
  String? _selectedRole;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    // 1. Validasi Input Dasar
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Semua field harus diisi!', Colors.redAccent);
      return;
    }

    if (_selectedRole == null) {
      _showSnackBar('Silakan pilih peran (role) Anda!', Colors.redAccent);
      return;
    }

    // 2. Set loading state
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // Tutup keyboard

    // 3. Panggil API Register
    final responseData = await _authService.register(
      username: username,
      email: email,
      password: password,
      role: _selectedRole!, // Mengirim role yang dipilih
      firstName: firstName.isEmpty ? null : firstName,
      lastName: lastName.isEmpty ? null : lastName,
    );

    // 4. Set loading selesai
    setState(() => _isLoading = false);

    if (!mounted) return;

    // 5. Cek response
    if (responseData['status'] == true) {
      // === REGISTER SUKSES ===
      _showSnackBar('Registrasi berhasil! Silakan login.', Colors.green);

      // Kembali ke layar login setelah 1.5 detik agar user membaca pesan
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pop(context); // Kembali ke halaman sebelumnya (LoginScreen)
        }
      });

    } else {
      // === REGISTER GAGAL ===
      // Tampilkan pesan error dari server (misal: Username sudah ada)
      String message = responseData['message'] ?? 'Registrasi gagal.';
      _showErrorDialog(message);
    }
  }

  // Helper untuk menampilkan SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // Helper untuk menampilkan Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrasi Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Daftar Akun Baru"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF111827),
                  Color(0xFF0F1624),
                  Color(0xFF1a2f4f),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_add_alt_1, size: 40, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Buat Akun Courtify",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_usernameController, 'Username', Icons.person),
                    const SizedBox(height: 14),
                    _buildTextField(_emailController, 'Email', Icons.email, inputType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _buildTextField(_firstNameController, 'Nama Depan (opsional)', Icons.badge, isRequired: false),
                    const SizedBox(height: 14),
                    _buildTextField(_lastNameController, 'Nama Belakang (opsional)', Icons.badge_outlined, isRequired: false),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: accent),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: cardColor,
                          value: _selectedRole,
                          hint: const Text("Pilih Peran (Role)", style: TextStyle(color: Colors.white70)),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_circle, color: accent),
                          items: const [
                            DropdownMenuItem(
                              value: 'user',
                              child: Row(children: [Icon(Icons.person_outline, color: Colors.white70), SizedBox(width: 10), Text("Pengguna Biasa")]),
                            ),
                            DropdownMenuItem(
                              value: 'penyedia',
                              child: Row(children: [Icon(Icons.store_outlined, color: Colors.white70), SizedBox(width: 10), Text("Penyedia Lapangan")]),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: accent))
                        : ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              "Daftar Sekarang",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk membuat TextField standar
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    bool isRequired = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: accent),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
      ),
    );
  }
}
