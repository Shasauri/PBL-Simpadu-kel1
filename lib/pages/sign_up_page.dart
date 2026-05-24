import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Warna sesuai tema desain kamu
  final Color primaryBlue = const Color.fromRGBO(21, 101, 216, 1);
  final Color greyTextColor = const Color.fromRGBO(149, 158, 173, 1);
  final Color inputBorderColor = const Color.fromARGB(149, 158, 173, 208);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. HEADER (Logo & Name) ---
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/LogoPoliban.png',
                          height: 48,
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
                    const SizedBox(height: 50),

                    // --- 2. TITLE ---
                    Center(
                      child: const Text(
                        "Daftarkan akun anda",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101828),
                          fontFamily: 'SansSerif',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Gabung bersama kami dan akses akun anda",
                        style: TextStyle(
                          fontSize: 14,
                          color: greyTextColor,
                          fontFamily: 'SansSerif',
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- 3. FORM FIELDS ---
                    _buildInputLabel("Email address"),
                    _buildTextField(_emailController, "Enter email", false),
                    const SizedBox(height: 20),

                    _buildInputLabel("Password"),
                    _buildPasswordField(
                      _passwordController,
                      "Enter password",
                      _obscurePassword,
                      () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildInputLabel("Confirmation Password"),
                    _buildPasswordField(
                      _confirmPasswordController,
                      "Enter confirmation password",
                      _obscureConfirmPassword,
                      () {
                        setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- 4. SIGN UP BUTTON (With Gradient) ---
                    _buildSignUpButton(),
                    const SizedBox(height: 24),

                    // --- 8. SIGN IN LINK ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun? ",
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
                  ],
                ),
              ),
            ),

            // --- 9. FOOTER (Tetap di bawah) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Privacy  •  Terms & Condition",
                      style: TextStyle(
                        fontSize: 12,
                        color: greyTextColor,
                        fontFamily: 'SansSerif',
                      ),
                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool obscure,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
      ),
    );
  }

  Widget _buildSignUpButton() {
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
          "Daftar Sekarang",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
