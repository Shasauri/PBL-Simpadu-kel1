import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InformasiPribadiPage extends StatefulWidget {
  const InformasiPribadiPage({super.key});

  @override
  State<InformasiPribadiPage> createState() => _InformasiPribadiPageState();
}

class _InformasiPribadiPageState extends State<InformasiPribadiPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  // Di dalam file informasi_pribadi_page.dart

  Future<void> _fetchDetailData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nameController.text =
          prefs.getString('admin_name') ?? "Super Administrator";
      emailController.text =
          prefs.getString('admin_email') ?? "superadmin@simpadu.ac.id";
      roleController.text = prefs.getString('admin_role') ?? "Super Admin";
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Tombol Kembali di Pojok Kiri Atas
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF344054),
                size: 16,
              ),
              onPressed: () => Navigator.pop(
                context,
              ), // Kembali ke halaman profil sebelumnya
            ),
          ),
        ),
        title: const Text(
          "Informasi Pribadi",
          style: TextStyle(
            color: Color(0xFF1D2939),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'SansSerif',
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar tengah
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundImage: AssetImage(
                            'assets/images/profilSuperAdminS.png',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form field
                  _buildDisabledField(
                    label: "Nama Lengkap",
                    controller: nameController,
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildDisabledField(
                    label: "Alamat Email",
                    controller: emailController,
                    icon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Role Akun dengan lambang Gembok Terkunci (Read-Only)
                  _buildDisabledField(
                    label: "Role Akun",
                    controller: roleController,
                    icon: Icons.lock_outline_rounded,
                    isLocked: true,
                  ),

                  const SizedBox(height: 40),

                  // Tombol Simpan Perubahan
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Dapat ditambah logika update profil nama/email jika endpoint PUT di masa depan mendukung
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Perubahan profil berhasil disimpan!",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF1570EF,
                        ), // Warna biru Simpadu
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Simpan Perubahan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'SansSerif',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDisabledField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isLocked = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF344054),
            fontFamily: 'SansSerif',
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: isLocked, // Dikunci jika merupakan field Role Akun
          decoration: InputDecoration(
            fillColor: isLocked ? const Color(0xFFF9FAFB) : Colors.white,
            filled: isLocked,
            prefixIcon: Icon(icon, color: const Color(0xFF98A2B3), size: 20),
            suffixIcon: isLocked
                ? const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF98A2B3),
                    size: 18,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
          ),
        ),
      ],
    );
  }
}
