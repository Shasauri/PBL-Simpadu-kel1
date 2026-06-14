import 'package:flutter/material.dart';
import 'package:mobile_kel1/pages/adminAkademik/kelas_page.dart';
import 'package:mobile_kel1/pages/adminAkademik/prodi_jurusan_page.dart';
import 'package:mobile_kel1/pages/adminAkademik/profil_admin_akademik_page.dart';
import 'package:mobile_kel1/pages/adminAkademik/tahun_akademik_page.dart';
import 'package:mobile_kel1/pages/login_page.dart';
import 'package:mobile_kel1/services/academic_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../services/academic_service.dart';
// import 'login_page.dart'; // Sesuaikan lokasi file login Anda

class DashboardAdminAkademik extends StatefulWidget {
  const DashboardAdminAkademik({super.key});

  @override
  State<DashboardAdminAkademik> createState() => _DashboardAdminAkademikState();
}

class _DashboardAdminAkademikState extends State<DashboardAdminAkademik> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color textDarkColor = const Color(0xFF101828);
  final Color primaryBlue = const Color(0xFF2D62ED);

  // State Data Penyimpan API
  int mhsCount = 0;
  int dsnCount = 0;
  int kelasCount = 0;
  int mkCount = 0;
  List<dynamic> activeKelasList = [];
  List<dynamic> activeTahunAkademik = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);

    final int dataMhs = await AcademicService.fetchMahasiswaCount();
    final int dataDsn = await AcademicService.fetchDosenCount();
    final List<dynamic> dataKelas = await AcademicService.fetchKelas();
    final int dataMk = await AcademicService.fetchMataKuliahCount();
    final List<dynamic> dataTA = await AcademicService.fetchTahunAkademik();

    setState(() {
      mhsCount = dataMhs;
      dsnCount = dataDsn;
      kelasCount = dataKelas.length;
      activeKelasList = dataKelas.where((k) => k['status'] == 'aktif').toList();
      mkCount = dataMk;
      activeTahunAkademik = dataTA;
      isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),

      // --- APP BAR UTAMA ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu_rounded,
            color: Color(0xFF101828),
            size: 28,
          ),
          onPressed: () =>
              _scaffoldKey.currentState?.openDrawer(), // Buka Sidebar
        ),
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Color(0xFF2D62ED),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'SansSerif',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF2D62ED),
              child: const Text(
                "NA",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SansSerif',
                ),
              ),
            ),
          ),
        ],
      ),

      // --- SIDEBAR MENU (DRAWER) ---
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFFDFDFD),
          child: Column(
            children: [
              // Header Sidebar
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "SIMPADU",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SansSerif',
                                fontSize: 16,
                                color: Color(0xFF1570EF),
                              ),
                            ),
                            const Text(
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

              // List Menu Utama
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
                      isActive: true,
                      onTap: () => Navigator.pop(context), // Sudah di dashboard, cukup tutup drawer
                    ),
                    _buildDrawerItem(
                      icon: Icons.calendar_today_rounded,
                      label: "Tahun Akademik",
                      onTap: () {
                        Navigator.pop(context); // Tutup drawer
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const JurusanProdiPage()));
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.meeting_room_outlined,
                      label: "Kelas",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const KelasPage()));
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.badge_outlined,
                      label: "Dosen",
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.assignment_turned_in_outlined,
                      label: "Presensi",
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.book_outlined,
                      label: "Mata Kuliah",
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.analytics_outlined,
                      label: "Nilai",
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.description_outlined,
                      label: "Kartu Hasil Studi",
                      onTap: () {
                        Navigator.pop(context);
                      },
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
                            builder: (context) => const ProfilePageAdminAkademik(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Tombol Keluar Akun di Bagian Bawah Sidebar
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // --- KONTEN HALAMAN DASHBOARD ---
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ucapan Selamat Datang
                    const Text(
                      "Selamat Datang,",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                        fontFamily: 'SansSerif',
                      ),
                    ),
                    const Text(
                      "Admin Akademik!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D62ED),
                        fontFamily: 'SansSerif',
                      ),
                    ),
                    const Text(
                      "Tinjauan cepat operasional SIMPADU.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF667085),
                        fontFamily: 'SansSerif',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Grid 4 Buah Card Statistik Angka
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard(
                          "Mahasiswa",
                          mhsCount.toString(),
                          Colors.blue,
                          Icons.people_outline,
                          Icons.school_outlined,
                        ),
                        _buildStatCard(
                          "Dosen Aktif",
                          dsnCount.toString(),
                          Colors.orange,
                          Icons.work_outline,
                          Icons.workspace_premium_outlined,
                        ),
                        _buildStatCard(
                          "Total Kelas",
                          kelasCount.toString(),
                          Colors.lightBlue,
                          Icons.door_sliding_outlined,
                          Icons.meeting_room_outlined,
                        ),
                        _buildStatCard(
                          "Mata Kuliah",
                          mkCount.toString(),
                          Colors.green,
                          Icons.menu_book_outlined,
                          Icons.import_contacts_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Komponen Kalender Akademik
                    _buildCalendarSection(),
                    const SizedBox(height: 24),

                    // Status Tahun Akademik Aktif
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Status Tahun Akademik",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101828),
                            fontFamily: 'SansSerif',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Alur navigasi ke halaman list tahun akademik
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TahunAkademikPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Lihat Semua",
                            style: TextStyle(
                              color: Color(0xFF2D62ED),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTahunAkademikSection(),
                    const SizedBox(height: 24),

                    // Daftar Kelas Aktif
                    const Text(
                      "Daftar Kelas Aktif",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                        fontFamily: 'SansSerif',
                      ),
                    ),
                    const Text(
                      "Kapasitas kelas di periode berjalan",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667085),
                        fontFamily: 'SansSerif',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDaftarKelasSection(),
                  ],
                ),
              ),
            ),
    );
  }

  // --- COMPONENT BUILDERS (REUSABLE WIDGET) ---

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF2D62ED)
            : Colors.transparent, // Highlight biru jika aktif
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

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
    IconData bgIcon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2F4F7)),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              bgIcon,
              color: color.withOpacity(0.06),
              size: 48,
            ), // Watermark background icon
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 16),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF667085),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SansSerif',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                      fontFamily: 'SansSerif',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildCalendarSection() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF2F4F7))),
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text("Kalender Akademik", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D62ED))),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //               decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(20)),
  //               child: const Row(
  //                 children: [
  //                   Text("Juni 2026 ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF344054))),
  //                   Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF344054)),
  //                 ],
  //               ),
  //             )
  //           ],
  //         ),
  //         TableCalendar(
  //           firstDay: DateTime.utc(2020, 1, 1),
  //           lastDay: DateTime.utc(2030, 12, 31),
  //           focusedDay: DateTime.utc(2026, 6, 8),
  //           calendarFormat: CalendarFormat.month,
  //           headerVisible: false, // Sembunyikan header bawaan agar rapi
  //           calendarStyle: const CalendarStyle(
  //             todayDecoration: BoxDecoration(color: Color(0xFF2D62ED), shape: BoxShape.circle),
  //             defaultTextStyle: TextStyle(fontSize: 12, color: Color(0xFF101828)),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCalendarSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F4F7)),
      ),
      child: TableCalendar(
        // Batasan tanggal yang bisa dilihat di kalender (Tahun 2026 sesuai mockup)
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: DateTime.utc(
          2026,
          5,
          20,
        ), // Diarahkan ke Mei 2026 sesuai mockup
        // Mengatur format kalender menjadi 1 minggu saja (CalendarFormat.week)
        // atau sebulan penuh (CalendarFormat.month) sesuai kebutuhan layout mobile
        calendarFormat: CalendarFormat.month,

        // --- KUSTOMISASI HEADER (Bulan & Tahun) ---
        headerStyle: HeaderStyle(
          formatButtonVisible:
              false, // Sembunyikan tombol format '2 weeks / month' bawaan yang mengganggu
          titleCentered: true, // Judul bulan di tengah sesuai desain
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textDarkColor,
            fontFamily: 'SansSerif',
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.grey),
          rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.grey),
        ),

        // --- KUSTOMISASI GAYA TANGGAL ---
        calendarStyle: CalendarStyle(
          isTodayHighlighted: true,
          // Gaya untuk hari ini (Today)
          todayDecoration: BoxDecoration(
            color: primaryBlue, // Warna biru utama kamu
            shape: BoxShape.circle,
          ),
          // Gaya untuk tanggal terpilih/biasa
          defaultTextStyle: TextStyle(
            color: textDarkColor,
            fontFamily: 'SansSerif',
          ),
          weekendTextStyle: const TextStyle(
            color: Colors.red,
            fontFamily: 'SansSerif',
          ), // Warna merah untuk sabtu-minggu
        ),

        // --- KUSTOMISASI NAMA HARI (Sen, Sel, Rab...) ---
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Color(0xFF667085),
            fontWeight: FontWeight.w500,
            fontSize: 12,
            fontFamily: 'SansSerif',
          ),
          weekendStyle: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            fontFamily: 'SansSerif',
          ),
        ),
      ),
    );
  }

  Widget _buildTahunAkademikSection() {
    if (activeTahunAkademik.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Tidak ada tahun akademik aktif.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontFamily: 'SansSerif',
            ),
          ),
        ),
      );
    }
    return Column(
      children: activeTahunAkademik.map((ta) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF), // Biru soft transparan
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFB2CCFF)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFD1E9FF),
                child: Icon(Icons.check, color: Color(0xFF2D62ED), size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ta['id'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                        fontSize: 14,
                        fontFamily: 'SansSerif',
                      ),
                    ),
                    Text(
                      ta['tahun_akademik'] ?? "",
                      style: const TextStyle(
                        color: Color(0xFF2D62ED),
                        fontSize: 12,
                        fontFamily: 'SansSerif',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D62ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Aktif",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SansSerif',
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaftarKelasSection() {
    if (activeKelasList.isEmpty) {
      return const Center(child: Text("Tidak ada kelas aktif saat ini."));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeKelasList.length,
      itemBuilder: (context, index) {
        final kelas = activeKelasList[index];
        int mhsCount = kelas['jumlah_mahasiswa'] ?? 0;
        int kapasitas = kelas['kapasitas_mahasiswa'] ?? 40;
        bool isFull = mhsCount >= kapasitas;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF2F4F7)),
          ),
          child: Row(
            children: [
              // Garis indikator vertikal di samping kiri card
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: isFull ? Colors.red : const Color(0xFF12B76A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kelas['kode_kelas'] ?? "-",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF101828),
                        fontFamily: 'SansSerif',
                      ),
                    ),
                    Text(
                      kelas['nama_kelas'] ?? "-",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF344054),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SansSerif',
                      ),
                    ),
                    Text(
                      kelas['prodi']?['nama_prodi'] ?? "-",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF98A2B3),
                        fontFamily: 'SansSerif',
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Aktif",
                      style: TextStyle(
                        color: Color(0xFF027A48),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SansSerif',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: Text(
                      "$mhsCount/$kapasitas", // Rasio isi kapasitas mahasiswa
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isFull ? Colors.red : const Color(0xFF344054),
                        fontFamily: 'SansSerif',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
