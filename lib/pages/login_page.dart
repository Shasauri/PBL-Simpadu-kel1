import 'package:flutter/material.dart';
// import 'package:http/http.dart';
import 'package:mobile_kel1/pages/adminAkademik/dashboard_admin_akademik_page.dart';
// import 'package:mobile_kel1/pages/dashboard_admin_akademik_page.dart';
import 'package:mobile_kel1/services/auth_service.dart';
import 'package:mobile_kel1/pages/dashboard_super_admin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk mengambil teks dari inputan
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginError = false; // Menandai apakah login gagal atau tidak

  // State untuk checkbox "Keep me sign in"
  bool _keepMeSignedIn = false;

  // State untuk menyembunyikan/menampilkan password
  bool _obscurePassword = true;

  // Warna-warna utama sesuai desain
  final Color primaryBlue = const Color(0xFF2D62ED);
  final Color greyTextColor = const Color(0xFF667085);
  final Color inputBorderColor = const Color(0xFFD0D5DD);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Bungkus dengan SingleChildScrollView agar layar bisa di-scroll saat keyboard muncul
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER (Logo & Text SIMPADU) ---
              Row(
                children: [
                  // Ganti 'assets/images/logo_poliban.png' dengan path aset kamu
                  Image.asset(
                    'assets/images/LogoPoliban.png',
                    height: 48,
                    errorBuilder: (context, error, stackTrace) {
                      // Placeholder jika gambar gagal dimuat
                      return Container(
                        height: 48,
                        width: 48,
                        color: Colors.grey[200],
                        child: const Icon(Icons.school_outlined, size: 30),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "SIMPADU POLIBAN",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2939),
                      fontFamily: 'SansSerif',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // --- 2. WELCOME TEXT ---
              Center(
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Selamat Datang",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                      fontFamily: 'SansSerif',
                    ),
                  ),
                ),
              ),

              const Center(
                child: Text(
                  "Sistem Informasi Terpadu\n Politeknik Negeri Banjarmasin",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontFamily: 'SansSerif'),
                ),
              ),
              const SizedBox(height: 24),

              _buildErrorBanner(),

              // --- 5. EMAIL INPUT ---
              _buildInputLabel("Email"),
              _buildEmailField(),
              const SizedBox(height: 24),

              // --- 6. PASSWORD INPUT ---
              _buildInputLabel("Password"),
              _buildPasswordField(),
              const SizedBox(height: 16),

              // --- 7. CHECKBOX & FORGOT PASSWORD ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _keepMeSignedIn,
                          activeColor: primaryBlue,
                          side: BorderSide(color: inputBorderColor),
                          onChanged: (value) {
                            setState(() {
                              _keepMeSignedIn = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Tetap Masuk",
                        style: TextStyle(
                          color: greyTextColor,
                          fontSize: 14,
                          fontFamily: 'SansSerif',
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Navigasi ke halaman lupa password");
                    },
                    child: Text(
                      "Lupa Kata Sandi?",
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'SansSerif',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- 8. LOGIN BUTTON ---
              _buildLoginButton(),
              const SizedBox(height: 24),

              // --- 10. FOOTER ---
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "© 2026 Politeknik Negeri Banjarmasin. All rights reserved.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF98A2B3),
                    fontFamily: 'SansSerif',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF344054),
          fontFamily: 'SansSerif',
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: "Masukkan email",
        hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'SansSerif'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primaryBlue, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: "Masukkan kata sandi",
        hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'SansSerif'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primaryBlue, width: 2.0),
        ),
        // Suffix icon untuk menyembunyikan/menampilkan password
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

 Widget _buildLoginButton() {
  return SizedBox(
    width: double.infinity,
    height: 48.0,
    child: ElevatedButton(
      onPressed: () async {
        final String email = _emailController.text.trim();
        final String password = _passwordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
          setState(() {
            _isLoginError = true;
          });
          return;
        }

        try {
          // Memanggil fungsi login dari AuthService
          final authService = AuthService();
          final response = await authService.login(email, password);

          // Ambil instance untuk memeriksa role yang disimpan oleh service
          final prefs = await SharedPreferences.getInstance();
          final String? savedRole = prefs.getString('admin_role');

          if (mounted) {
            // Pengondisian Navigasi Berdasarkan Jenis Akun / Role
            if (savedRole == 'Admin Academic' || email.contains('akademik')) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardAdminAkademik(),
                ),
              );
            } else {
              // Jika bukan admin akademik, arahkan ke dashboard super admin bawaan
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardSuperAdmin(),
                ),
              );
            }
          }
        } catch (e) {
          print("Login Error Exception di UI: $e");
          // Tampilkan banner merah jika response server gagal/error
          setState(() {
            _isLoginError = true;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: const Text(
        "Masuk",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'SansSerif',
        ),
      ),
    ),
  );
}

  Widget _buildErrorBanner() {
    if (!_isLoginError)
      return const SizedBox.shrink(); // Jika tidak error, sembunyikan widget ini

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      margin: const EdgeInsets.only(
        bottom: 24.0,
      ), // Jarak aman ke kolom input Email
      decoration: BoxDecoration(
        color: const Color(
          0xFFBC0000,
        ), // Warna merah solid sesuai gambar desain
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Text(
        "Email atau Kata Sandi salah. Silakan coba lagi",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'SansSerif',
        ),
      ),
    );
  }
}
