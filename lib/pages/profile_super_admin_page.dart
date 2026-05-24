import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'informasi_pribadi_page.dart';
import 'ubah_kata_sandi_page.dart';
import 'login_page.dart'; // Sesuaikan dengan file login Anda

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String adminName = "Memuat...";
  String adminEmail = "Memuat...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminProfileFromLocal();
  }

  Future<void> _loadAdminProfileFromLocal() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      adminName = prefs.getString('admin_name') ?? "Super Administrator";
      adminEmail = prefs.getString('admin_email') ?? "Superadmin@simpadu.ac.id";
      isLoading = false;
    });
  }

  // Fungsi Log Out untuk menghapus session token dan kembali ke halaman login
  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Hapus token dari penyimpanan lokal

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ), // Kembali ke login screen
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profil",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'SansSerif',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 1. BAGIAN AVATAR DAN BADGE NAMA
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                          'assets/images/profilSuperAdminS.png',
                        ), // Tambahkan placeholder foto Anda
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    adminName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2939),
                      fontFamily: 'SansSerif',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adminEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF667085),
                      fontFamily: 'SansSerif',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Badge Super Admin
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF8FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Super Admin",
                      style: TextStyle(
                        color: Color(0xFF175CD3),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'SansSerif',
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. KELOMPOK PENGATURAN AKUN
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Pengaturan Akun",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontFamily: 'SansSerif',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Menu List Card Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF2F4F7)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x05101828),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: "Informasi Pribadi",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const InformasiPribadiPage(),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(height: 1),
                        ),
                        _buildMenuTile(
                          icon: Icons.lock_open_outlined,
                          title: "Ubah Kata Sandi",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UbahKataSandiPage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // 3. TOMBOL KELUAR AKUN (LOGOUT BUTTON)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _handleLogout,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFFDA29B),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFB42318),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Keluar Akun",
                              style: TextStyle(
                                color: Color(0xFFB42318),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'SansSerif',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF475467), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF344054),
          fontFamily: 'SansSerif',
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Color(0xFF98A2B3),
      ),
      onTap: onTap,
    );
  }
}
