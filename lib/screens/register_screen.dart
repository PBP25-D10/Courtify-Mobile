import 'package:flutter/material.dart';
import 'package:courtify_mobile/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
      appBar: AppBar(
        title: const Text("Daftar Akun Baru"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_add_alt_1, size: 60, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                "Buat Akun Courtify",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // --- Form Inputs ---
              // Username Input
              _buildTextField(_usernameController, 'Username', Icons.person),
              const SizedBox(height: 16),
              // Email Input
              _buildTextField(_emailController, 'Email', Icons.email, inputType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              // First name (opsional)
              _buildTextField(_firstNameController, 'Nama Depan (opsional)', Icons.badge, isRequired: false),
              const SizedBox(height: 16),
              // Last name (opsional)
              _buildTextField(_lastNameController, 'Nama Belakang (opsional)', Icons.badge_outlined, isRequired: false),
              const SizedBox(height: 16),
              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 16),

              // --- Role Selection (Dropdown) ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    hint: const Text("Pilih Peran (Role)"),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.blueAccent),
                    items: const [
                      DropdownMenuItem(
                        value: 'user',
                        child: Row(children: [Icon(Icons.person_outline), SizedBox(width: 10), Text("Pengguna Biasa")]),
                      ),
                      DropdownMenuItem(
                        value: 'penyedia',
                        child: Row(children: [Icon(Icons.store_outlined), SizedBox(width: 10), Text("Penyedia Lapangan")]),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- Tombol Register ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: const Text(
                        "DAFTAR SEKARANG",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
