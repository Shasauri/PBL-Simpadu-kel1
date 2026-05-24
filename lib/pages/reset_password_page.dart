import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Warna sesuai tema desain kamu
  final Color primaryBlue = const Color.fromRGBO(21, 101, 216, 1);
  final Color greyTextColor = const Color.fromRGBO(149, 158, 173, 1);
  final Color inputBorderColor = const Color.fromARGB(149, 158, 173, 208);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Mayoritas konten di sini center
            children: [
              // --- 1. HEADER (Logo & Name) ---
              Row(
                children: [
                  Image.asset(
                    'assets/images/LogoPoliban.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.school, size: 40),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "SIMPADU POLIBAN",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SansSerif',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // --- 2. TITLE & SUBTITLE ---
              const Text(
                "Buat Kata Sandi Baru",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828),
                  fontFamily: 'SansSerif',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Buat kata sandi baru untuk akun POLIBAN Anda\ndengan mengisi formulir di bawah ini.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: greyTextColor,
                  height: 1.5,
                  fontFamily: 'SansSerif',
                ),
              ),
              const SizedBox(height: 40),

              // --- 3. FORM FIELDS ---
              Align(
                alignment: Alignment.centerLeft,
                child: _buildInputLabel("Kata Sandi"),
              ),
              _buildPasswordField(
                _passwordController,
                "Masukkan Kata Sandi",
                _obscurePassword,
                () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: _buildInputLabel("Konfirmasi Kata Sandi"),
              ),
              _buildPasswordField(
                _confirmPasswordController,
                "Masukkan Kembali Kata Sandi",
                _obscureConfirmPassword,
                () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
              const SizedBox(height: 32),

              // --- 4. CONFIRM BUTTON (Gradient) ---
              _buildConfirmButton(),
              const SizedBox(height: 32),

              // --- 5. INFO TEXT ---
              Text(
                "Jika Anda tidak melihat informasi pembuatan ulang\nkata sandi akun Anda, silakan periksa kembali nanti.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  height: 1.5,
                  fontFamily: 'SansSerif',
                ),
              ),
              const SizedBox(height: 40),

              // --- 6. GO BACK LINK ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Ingat kata sandi anda? ",
                    style: TextStyle(
                      color: greyTextColor,
                      fontFamily: 'SansSerif',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Kembali ke Login
                    child: Text(
                      "Masuk",
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SansSerif',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // --- 7. FOOTER ---
              Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "© 2026 Politeknik Negeri Banjarmasin. All rights reserved.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                      fontFamily: 'SansSerif',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF344054),
          fontFamily: 'SansSerif',
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hint,
    bool obscure,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey,
            size: 20,
          ),
          onPressed: toggle,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          "Confirm",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
