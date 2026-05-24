import 'package:flutter/material.dart';
import 'package:mobile_kel1/services/auth_service.dart';

class UbahKataSandiPage extends StatefulWidget {
  const UbahKataSandiPage({super.key});

  @override
  State<UbahKataSandiPage> createState() => _UbahKataSandiPageState();
}

class _UbahKataSandiPageState extends State<UbahKataSandiPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = false; // Dibuka awal seperti di mockup
  bool _obscureConfirm = true;

  // Variabel Kriteria Validasi Pasword
  bool hasMinLength = false;
  bool hasUpperLower = false;
  bool hasNumberSymbol = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  // Fungsi pengecekan kriteria kata sandi secara real-time
  void _validatePassword() {
    final text = _newPasswordController.text;
    setState(() {
      hasMinLength = text.length >= 8;
      hasUpperLower = text.contains(RegExp(r'[A-Z]')) && text.contains(RegExp(r'[a-z]'));
      hasNumberSymbol = text.contains(RegExp(r'[0-9]')) || text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_]'));
    });
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_validatePassword);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Tombol Kembali Pojok Kiri Atas
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(8)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF344054), size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text("Ubah Kata Sandi", style: TextStyle(color: Color(0xFF1D2939), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon gembok di atas
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline_rounded, size: 32, color: Color(0xFF1570EF)),
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text("Buat kata sandi yang kuat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D2939)))),
            const Center(child: Text("Amankan akun Anda dengan kombinasi yang unik.", style: TextStyle(color: Color(0xFF667085), fontSize: 13))),
            const SizedBox(height: 24),

            // 1. Field Kata Sandi Saat Ini
            _buildPasswordField(
              label: "Kata Sandi Saat Ini",
              controller: _currentPasswordController,
              obscure: _obscureCurrent,
              onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 16),

            // 2. Field Kata Sandi Baru
            _buildPasswordField(
              label: "Kata Sandi Baru",
              controller: _newPasswordController,
              obscure: _obscureNew,
              onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
              isFocusedStyle: true,
            ),
            const SizedBox(height: 16),

            // 3. Field Konfirmasi Kata Sandi Baru
            _buildPasswordField(
              label: "Konfirmasi Kata Sandi Baru",
              controller: _confirmPasswordController,
              obscure: _obscureConfirm,
              onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 20),

            // Kriteria Kata Sandi Komponen
            const Text("Kriteria kata sandi yang aman:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF344054))),
            const SizedBox(height: 8),
            _buildCriteriaItem(text: "Minimal terdiri dari 8 karakter", isValid: hasMinLength),
            _buildCriteriaItem(text: "Mengandug huruf besar dan kecil", isValid: hasUpperLower),
            _buildCriteriaItem(text: "Mengandung angka dan simbol spesial", isValid: hasNumberSymbol),

            const SizedBox(height: 40),

            // Tombol Perbarui Kata Sandi
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  if (_newPasswordController.text != _confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konfirmasi kata sandi tidak cocok!"), backgroundColor: Colors.red));
                    return;
                  }
                  if (!hasMinLength || !hasUpperLower || !hasNumberSymbol) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kata sandi belum memenuhi kriteria keamanan!"), backgroundColor: Colors.red));
                    return;
                  }

                  bool success = await AuthService.updateSuperAdminPassword(_newPasswordController.text);
                  if (success) {
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                    
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kata sandi berhasil diperbarui!"), backgroundColor: Colors.green));
                    Navigator.pop(context); // Kembali ke menu utama profil
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memperbarui kata sandi."), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1570EF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text("Perbarui Kata Sandi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggleVisibility,
    bool isFocusedStyle = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF344054))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF98A2B3), size: 20),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isFocusedStyle ? const Color(0xFF1570EF) : const Color(0xFFD0D5DD), width: isFocusedStyle ? 2 : 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isFocusedStyle ? const Color(0xFF1570EF) : const Color(0xFFD0D5DD), width: isFocusedStyle ? 1.5 : 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCriteriaItem({required String text, required bool isValid}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.check_circle_outline_rounded,
            color: isValid ? const Color(0xFF12B76A) : const Color(0xFFD0D5DD), // Hijau aktif jika valid
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF475467))),
        ],
      ),
    );
  }
}