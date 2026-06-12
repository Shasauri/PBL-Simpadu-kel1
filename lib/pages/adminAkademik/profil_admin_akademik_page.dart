import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_kel1/pages/login_page.dart';

class ProfilePageAdminAkademik extends StatefulWidget {
  const ProfilePageAdminAkademik({super.key});

  @override
  State<ProfilePageAdminAkademik> createState() => _ProfilePageAdminAkademikState();
}

class _ProfilePageAdminAkademikState extends State<ProfilePageAdminAkademik> {
  String adminName = "Admin Akademik";
  String adminEmail = "admin.akademik@simpadu.ac.id";
  String adminNip = "AA001";
  bool _isLoading = true;

  // Controllers untuk form informasi pribadi
  late TextEditingController _nameController;
  late TextEditingController _nipController;
  late TextEditingController _emailController;

  // Controllers untuk form ubah password
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nipController = TextEditingController();
    _emailController = TextEditingController();
    _loadLocalProfile();
  }

  Future<void> _loadLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('admin_name') ?? "Admin Akademik";
      adminEmail = prefs.getString('admin_email') ?? "admin.akademik@simpadu.ac.id";
      adminNip = prefs.getString('admin_nip') ?? "AA001";

      _nameController.text = adminName;
      _nipController.text = adminNip;
      _emailController.text = adminEmail;
      _isLoading = false;
    });
  }

  // Ambil inisial dari nama (maks 2 huruf)
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'AA';
  }

  void _handleSaveProfile() {
    // TODO: Implementasi simpan perubahan ke API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Perubahan berhasil disimpan"),
        backgroundColor: Color(0xFF2D62ED),
      ),
    );
  }

  void _handleUpdatePassword() {
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field kata sandi harus diisi"), backgroundColor: Colors.red),
      );
      return;
    }
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi kata sandi tidak cocok"), backgroundColor: Colors.red),
      );
      return;
    }
    // TODO: Implementasi update password ke API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Kata sandi berhasil diperbarui"), backgroundColor: Color(0xFF2D62ED)),
    );
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nipController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF101828), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profil Akun",
          style: TextStyle(
            color: Color(0xFF101828),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── HEADER / AVATAR SECTION ──────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: const Color(0xFFE8EEFF),
                              child: Text(
                                _getInitials(adminName),
                                style: const TextStyle(
                                  color: Color(0xFF2D62ED),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2D62ED),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Nama
                        Text(
                          adminName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Role
                        const Text(
                          "Admin Akademik",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Badge Aktif
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF12B76A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "Aktif",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF027A48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── INFORMASI PRIBADI SECTION ────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informasi Pribadi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Kelola data diri dasar untuk akun SIMPADU Anda.",
                          style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
                        ),
                        const SizedBox(height: 20),

                        // Nama Lengkap
                        _buildFormLabel("Nama Lengkap"),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _nameController,
                          hintText: "Masukkan nama lengkap",
                        ),
                        const SizedBox(height: 16),

                        // NIP / NIK
                        _buildFormLabel("Nomor Identitas (NIP / NIK)"),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _nipController,
                          hintText: "Nomor identitas",
                          isLocked: true,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _buildFormLabel("Alamat Email"),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _emailController,
                          hintText: "Alamat email",
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Hak Akses (read-only)
                        _buildFormLabel("Hak Akses Sistem"),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: TextEditingController(text: "Admin Akademik"),
                          hintText: "Hak akses",
                          isLocked: true,
                          enabled: false,
                        ),
                        const SizedBox(height: 24),

                        // Tombol Simpan
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D62ED),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _handleSaveProfile,
                            child: const Text(
                              "Simpan Perubahan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── UBAH KATA SANDI SECTION ──────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ubah Kata Sandi Akun",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Perbarui kata sandi Anda untuk menjaga keamanan.",
                          style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
                        ),
                        const SizedBox(height: 20),

                        // Kata Sandi Saat Ini
                        _buildFormLabel("Kata Sandi Saat Ini"),
                        const SizedBox(height: 6),
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          hintText: "Masukkan kata sandi saat ini...",
                          obscureText: _obscureCurrent,
                          onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        ),
                        const SizedBox(height: 16),

                        // Kata Sandi Baru
                        _buildFormLabel("Kata Sandi Baru"),
                        const SizedBox(height: 6),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          hintText: "Masukkan kata sandi baru...",
                          obscureText: _obscureNew,
                          onToggle: () => setState(() => _obscureNew = !_obscureNew),
                        ),
                        const SizedBox(height: 16),

                        // Konfirmasi Kata Sandi Baru
                        _buildFormLabel("Konfirmasi Kata Sandi Baru"),
                        const SizedBox(height: 6),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: "Ulangi kata sandi baru...",
                          obscureText: _obscureConfirm,
                          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        const SizedBox(height: 24),

                        // Tombol Perbarui Password
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD0D5DD), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _handleUpdatePassword,
                            child: const Text(
                              "Perbarui Password",
                              style: TextStyle(
                                color: Color(0xFF344054),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ── HELPER WIDGETS ─────────────────────────────────────────────────────────

  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF344054),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isLocked = false,
    bool enabled = true,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(fontSize: 14, color: Color(0xFF101828)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF9FAFB),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: const Color(0xFF98A2B3))
            : null,
        suffixIcon: isLocked
            ? const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF98A2B3))
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D62ED), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEAECF0)),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14, color: Color(0xFF101828)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: const Color(0xFF98A2B3),
          ),
          onPressed: onToggle,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D62ED), width: 1.5),
        ),
      ),
    );
  }
}