import 'package:flutter/material.dart';
import 'package:mobile_kel1/pages/adminAkademik/kelola_kelas_page.dart';
import 'package:mobile_kel1/pages/adminAkademik/dashboard_admin_akademik_page.dart';
import 'package:mobile_kel1/pages/adminAkademik/prodi_jurusan_page.dart';
import 'package:mobile_kel1/pages/adminAkademik/profil_admin_akademik_page.dart';
import 'package:mobile_kel1/pages/adminAkademik/tahun_akademik_page.dart';
import 'package:mobile_kel1/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/academic_service.dart';

class KelasPage extends StatefulWidget {
  const KelasPage({super.key});

  @override
  State<KelasPage> createState() => _KelasPageState();
}

class _KelasPageState extends State<KelasPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> _kelasList = [];
  List<dynamic> _filteredKelasList = [];
  List<dynamic> _tahunAkademikList = [];
  List<dynamic> _prodiList = [];

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final kelasData = await AcademicService.fetchAllKelas();
    final taData = await AcademicService.fetchAllTahunAkademik();
    final prodiData = await AcademicService.fetchProdi();

    setState(() {
      _kelasList = kelasData;
      _filteredKelasList = kelasData;
      _tahunAkademikList = taData;
      _prodiList = prodiData;
      _isLoading = false;
    });
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

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredKelasList = _kelasList.where((item) {
        final namaKelas = (item['nama_kelas'] ?? '').toString().toLowerCase();
        final kodeKelas = (item['kode_kelas'] ?? '').toString().toLowerCase();
        final prodiName = (item['prodi']?['nama_prodi'] ?? '')
            .toString()
            .toLowerCase();
        return namaKelas.contains(query) ||
            kodeKelas.contains(query) ||
            prodiName.contains(query);
      }).toList();
    });
  }

  // ==================== INTERFACE FORM MODAL (TAMBAH / UBAH) ====================
  void _openKelasFormFormModal({bool isEdit = false, int? idKelas}) async {
    int? selectedTaId;
    int? selectedProdiId;
    String selectedStatus = "aktif";

    final kodeController = TextEditingController();
    final namaController = TextEditingController();
    final kapasitasController = TextEditingController();
    final keteranganController = TextEditingController();

    if (isEdit && idKelas != null) {
      setState(() => _isLoading = true);
      final detail = await AcademicService.fetchDetailKelas(idKelas);
      setState(() => _isLoading = false);

      if (detail != null) {
        selectedTaId = detail['tahun_akademik_id'];
        selectedProdiId = detail['prodi_id'];
        selectedStatus = detail['status'] ?? "aktif";
        kodeController.text = detail['kode_kelas'] ?? "";
        namaController.text = detail['nama_kelas'] ?? "";
        kapasitasController.text = (detail['kapasitas_mahasiswa'] ?? "")
            .toString();
        keteranganController.text = detail['keterangan'] ?? "";
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 16,
                right: 16,
                top: 12,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAECF0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEdit ? "Ubah Kelas" : "Tambah Kelas",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                        fontFamily: "SansSerif",
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DROPDOWN TAHUN AKADEMIK
                    const Text(
                      "Tahun Akademik",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                        fontFamily: "SansSerif",
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: selectedTaId,
                      hint: const Text(
                        "Pilih Tahun Akademik",
                        style: TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 14,
                          fontFamily: "SansSerif",
                        ),
                      ),
                      items: _tahunAkademikList.map((ta) {
                        return DropdownMenuItem<int>(
                          value: ta['id'],
                          child: Text(
                            ta['tahun_akademik'] ?? "-",
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "SansSerif",
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setModalState(() => selectedTaId = val),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D5DD),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // DROPDOWN PROGRAM STUDI
                    const Text(
                      "Program Studi",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                        fontFamily: "SansSerif",
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: selectedProdiId,
                      hint: const Text(
                        "Pilih Program Studi",
                        style: TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 14,
                          fontFamily: "SansSerif",
                        ),
                      ),
                      items: _prodiList.map((prodi) {
                        return DropdownMenuItem<int>(
                          value: prodi['id'],
                          child: Text(
                            prodi['nama_prodi'] ?? "-",
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "SansSerif",
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setModalState(() => selectedProdiId = val),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D5DD),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // INPUT KODE KELAS
                    const Text(
                      "Kode Kelas",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                        fontFamily: "SansSerif",
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: kodeController,
                      decoration: InputDecoration(
                        hintText: "Contoh: TI-2A",
                        hintStyle: const TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 14,
                          fontFamily: "SansSerif",
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // INPUT NAMA KELAS
                    const Text(
                      "Nama Kelas",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                        fontFamily: "SansSerif",
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        hintText: "Contoh: Teknik Informatika 2A",
                        hintStyle: const TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 14,
                          fontFamily: "SansSerif",
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // INPUT KAPASITAS MAHASISWA
                    const Text(
                      "Kapasitas Mahasiswa",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                        fontFamily: "SansSerif",
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: kapasitasController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Masukkan angka kapasitas",
                        hintStyle: const TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 14,
                          fontFamily: "SansSerif",
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // DROPDOWN STATUS
                    const Text(
                      "Status Kelas",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                        fontFamily: "SansSerif",
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(
                          value: "aktif",
                          child: Text(
                            "Aktif",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "SansSerif",
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "nonaktif",
                          child: Text(
                            "Non-Aktif",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "SansSerif",
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) =>
                          setModalState(() => selectedStatus = val ?? "aktif"),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // INPUT KETERANGAN
                    const Text(
                      "Keterangan",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                        fontFamily: "SansSerif",
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: keteranganController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Masukkan keterangan opsional",
                        hintStyle: const TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 14,
                          fontFamily: "SansSerif",
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // TOMBOL AKSI SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D62ED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (selectedTaId == null ||
                              selectedProdiId == null ||
                              kodeController.text.isEmpty ||
                              namaController.text.isEmpty)
                            return;

                          Navigator.pop(context);
                          setState(() => _isLoading = true);

                          final bodyPayload = {
                            "tahun_akademik_id": selectedTaId,
                            "prodi_id": selectedProdiId,
                            "kode_kelas": kodeController.text.trim(),
                            "nama_kelas": namaController.text.trim(),
                            "kapasitas_mahasiswa":
                                int.tryParse(kapasitasController.text) ?? 0,
                            "status": selectedStatus,
                            "keterangan":
                                keteranganController.text.trim().isEmpty
                                ? null
                                : keteranganController.text.trim(),
                          };

                          bool success;
                          if (isEdit) {
                            success = await AcademicService.updateKelas(
                              idKelas!,
                              bodyPayload,
                            );
                          } else {
                            success = await AcademicService.createKelas(
                              bodyPayload,
                            );
                          }

                          if (success)
                            _showSnackBar(
                              isEdit
                                  ? "Data kelas berhasil diperbarui!"
                                  : "Kelas baru berhasil didaftarkan!",
                              Colors.green,
                            );
                          _loadInitialData();
                        },
                        child: const Text(
                          "Simpan Data Kelas",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "SansSerif",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2D62ED) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.white : const Color(0xFF475467),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF344054),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
            fontFamily: 'SansSerif',
          ),
        ),
        minLeadingWidth: 20,
        dense: true,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu_rounded,
            color: Color(0xFF101828),
            size: 28,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          "Daftar Kelas",
          style: TextStyle(
            color: Color(0xFF2D62ED),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: "SansSerif",
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFFDFDFD),
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/LogoPoliban.png',
                        height: 40,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.school,
                          size: 40,
                          color: Color(0xFF2D62ED),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SIMPADU",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SansSerif',
                                fontSize: 16,
                                color: Color(0xFF1570EF),
                              ),
                            ),
                            Text(
                              "Politeknik Negeri Banjarmasin",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF667085),
                                fontFamily: 'SansSerif',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF667085)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.grid_view_rounded,
                      label: "Dashboard",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DashboardAdminAkademik(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.calendar_today_rounded,
                      label: "Tahun Akademik",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TahunAkademikPage(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.account_balance_rounded,
                      label: "Jurusan dan Prodi",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JurusanProdiPage(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.meeting_room_outlined,
                      label: "Kelas",
                      isActive: true,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildDrawerItem(
                      icon: Icons.badge_outlined,
                      label: "Dosen",
                    ),
                    _buildDrawerItem(
                      icon: Icons.assignment_turned_in_outlined,
                      label: "Presensi",
                    ),
                    _buildDrawerItem(
                      icon: Icons.book_outlined,
                      label: "Mata Kuliah",
                    ),
                    _buildDrawerItem(
                      icon: Icons.analytics_outlined,
                      label: "Nilai",
                    ),
                    _buildDrawerItem(
                      icon: Icons.description_outlined,
                      label: "Kartu Hasil Studi",
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, top: 20, bottom: 8),
                      child: Text(
                        "AKUN",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF98A2B3),
                          letterSpacing: 1,
                          fontFamily: 'SansSerif',
                        ),
                      ),
                    ),
                    _buildDrawerItem(
                      icon: Icons.person_outline_rounded,
                      label: "Profil",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ProfilePageAdminAkademik(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFD92D20),
                  ),
                  title: const Text(
                    "Keluar Akun",
                    style: TextStyle(
                      color: Color(0xFFD92D20),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'SansSerif',
                    ),
                  ),
                  onTap: _handleLogout,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SEARCH BAR
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari kelas (mis. TI-2A)...",
                      hintStyle: const TextStyle(
                        color: Color(0xFF98A2B3),
                        fontSize: 14,
                        fontFamily: "SansSerif",
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF98A2B3),
                        size: 20,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2D62ED),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // FILTER + TAMBAH KELAS ROW
                  Row(
                    children: [
                      // FILTER BUTTON
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFD0D5DD)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {},
                            icon: const Icon(
                              Icons.tune_rounded,
                              color: Color(0xFF344054),
                              size: 18,
                            ),
                            label: const Text(
                              "Filter",
                              style: TextStyle(
                                color: Color(0xFF344054),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                fontFamily: "SansSerif",
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // TAMBAH KELAS BUTTON
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D62ED),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () =>
                                _openKelasFormFormModal(isEdit: false),
                            icon: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              "Tambah Kelas",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: "SansSerif",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // LIST KELAS
                  Expanded(
                    child: _filteredKelasList.isEmpty
                        ? const Center(
                            child: Text("Data kelas tidak ditemukan."),
                          )
                        : ListView.builder(
                            itemCount: _filteredKelasList.length,
                            itemBuilder: (context, index) {
                              final kelas = _filteredKelasList[index];
                              final int jmlMhs = kelas['jumlah_mahasiswa'] ?? 0;
                              final int kapasitas =
                                  kelas['kapasitas_mahasiswa'] ?? 0;
                              final String status =
                                  kelas['status'] ?? 'nonaktif';
                              final bool isAktif = status == 'aktif';
                              final bool isFull =
                                  kapasitas > 0 && jmlMhs >= kapasitas;

                              // Left border color: green for aktif, red for penuh, gray for nonaktif
                              final Color borderColor = !isAktif
                                  ? const Color(0xFFD0D5DD)
                                  : isFull
                                  ? const Color(0xFFF04438)
                                  : const Color(0xFF12B76A);

                              final String taLabel =
                                  kelas['tahun_akademik']?['tahun_akademik'] ??
                                  '-';
                              final String semester =
                                  kelas['tahun_akademik']?['semester'] ?? '';
                              final String taFull = semester.isNotEmpty
                                  ? "$taLabel ($semester)"
                                  : taLabel;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFEAECF0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // LEFT COLOR BORDER
                                        Container(width: 5, color: borderColor),
                                        // CARD CONTENT
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              14,
                                              14,
                                              14,
                                              12,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // TOP ROW: kode kelas, nama, status badge
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            kelas['kode_kelas'] ??
                                                                "-",
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      "SansSerif",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                    0xFF101828,
                                                                  ),
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            kelas['nama_kelas'] ??
                                                                "-",
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 13,
                                                                  fontFamily:
                                                                      "SansSerif",
                                                                  color: Color(
                                                                    0xFF2D62ED,
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            kelas['prodi']?['nama_prodi'] ??
                                                                "-",
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                    0xFF667085,
                                                                  ),
                                                                  fontFamily:
                                                                      "SansSerif",
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isAktif
                                                            ? const Color(
                                                                0xFFECFDF3,
                                                              )
                                                            : const Color(
                                                                0xFFF2F4F7,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        isAktif
                                                            ? "Aktif"
                                                            : "Non-Aktif",
                                                        style: TextStyle(
                                                          color: isAktif
                                                              ? const Color(
                                                                  0xFF027A48,
                                                                )
                                                              : const Color(
                                                                  0xFF667085,
                                                                ),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily:
                                                              "SansSerif",
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),

                                                // CHIPS ROW: TA + Kapasitas
                                                Row(
                                                  children: [
                                                    _buildChip(
                                                      Icons
                                                          .calendar_month_rounded,
                                                      taFull,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _buildCapacityChip(
                                                      jmlMhs,
                                                      kapasitas,
                                                      isFull,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                const Divider(
                                                  height: 1,
                                                  color: Color(0xFFF2F4F7),
                                                ),
                                                const SizedBox(height: 10),

                                                // ACTION BUTTONS ROW
                                                Row(
                                                  children: [
                                                    // KELOLA KELAS
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 36,
                                                        child: OutlinedButton.icon(
                                                          style: OutlinedButton.styleFrom(
                                                            side:
                                                                const BorderSide(
                                                                  color: Color(
                                                                    0xFFD0D5DD,
                                                                  ),
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            padding:
                                                                EdgeInsets.zero,
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    KelolaKelasPage(
                                                                      idKelas:
                                                                          kelas['id'],
                                                                    ),
                                                              ),
                                                            ).then(
                                                              (_) =>
                                                                  _loadInitialData(),
                                                            );
                                                          },
                                                          icon: const Icon(
                                                            Icons
                                                                .manage_accounts_rounded,
                                                            size: 16,
                                                            color: Color(
                                                              0xFF344054,
                                                            ),
                                                          ),
                                                          label: const Text(
                                                            "Kelola Kelas",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                0xFF344054,
                                                              ),
                                                              fontFamily:
                                                                  "SansSerif",
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // EDIT DATA
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 36,
                                                        child: OutlinedButton.icon(
                                                          style: OutlinedButton.styleFrom(
                                                            side:
                                                                const BorderSide(
                                                                  color: Color(
                                                                    0xFF2D62ED,
                                                                  ),
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            padding:
                                                                EdgeInsets.zero,
                                                          ),
                                                          onPressed: () =>
                                                              _openKelasFormFormModal(
                                                                isEdit: true,
                                                                idKelas:
                                                                    kelas['id'],
                                                              ),
                                                          icon: const Icon(
                                                            Icons.edit_outlined,
                                                            size: 16,
                                                            color: Color(
                                                              0xFF2D62ED,
                                                            ),
                                                          ),
                                                          label: const Text(
                                                            "Edit Data",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                0xFF2D62ED,
                                                              ),
                                                              fontFamily:
                                                                  "SansSerif",
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // FOOTER COUNT
                  if (_filteredKelasList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Center(
                        child: Text(
                          "Menampilkan ${_filteredKelasList.length} dari total ${_kelasList.length} data kelas",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF98A2B3),
                            fontFamily: "SansSerif",
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF667085)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w500,
              fontFamily: "SansSerif",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityChip(int current, int max, bool isFull) {
    final Color bgColor = isFull
        ? const Color(0xFFFEF3F2)
        : const Color(0xFFF2F4F7);
    final Color textColor = isFull
        ? const Color(0xFFF04438)
        : const Color(0xFF344054);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_alt_outlined,
            size: 12,
            color: isFull ? const Color(0xFFF04438) : const Color(0xFF667085),
          ),
          const SizedBox(width: 4),
          Text(
            "$current/$max",
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w600,
              fontFamily: "SansSerif",
            ),
          ),
        ],
      ),
    );
  }
}
