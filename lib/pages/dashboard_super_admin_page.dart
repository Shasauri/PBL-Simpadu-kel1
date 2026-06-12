import 'package:flutter/material.dart';
import 'package:mobile_kel1/models/user_model.dart';
import 'package:mobile_kel1/pages/akundanrole_super_admin_page.dart';
import 'package:mobile_kel1/pages/profile_super_admin_page.dart';
import 'package:mobile_kel1/services/user_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardSuperAdmin extends StatefulWidget {
  const DashboardSuperAdmin({super.key});

  @override
  State<DashboardSuperAdmin> createState() => _DashboardSuperAdminState();
}

class _DashboardSuperAdminState extends State<DashboardSuperAdmin> {
  // Index untuk Bottom Navigation Bar
  int _currentIndex = 0;

  // Warna utama sesuai panduan desain UI/UX
  final Color primaryBlue = const Color(0xFF2D62ED);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color textDarkColor = const Color(0xFF101828);

  List<Widget> _getPages() {
    return [
      _buildDashboardContent(), // Index 0: Konten utama Dashboard bawaan
      const AkundanroleSuperAdminPage(), // Index 1: Halaman Akun dan Role yang baru kita buat!
      const ProfilePage(), // Index 2: Tempatkan halaman profil nanti
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // --- AppBar Sesuai Desain ---
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                "Dashboard",
                style: TextStyle(
                  color: textDarkColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  fontFamily: 'SansSerif',
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(
                      'assets/images/profilSuperAdminS.png',
                    ),
                    // Ganti dengan profile picture super admin yang sesuai
                    backgroundColor: Colors.grey[300],
                    // child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ],
            ) 
            : null,

      // --- Isi Konten (Hanya tampil jika index = 0 / Dashboard) ---
      body: _getPages()[_currentIndex],

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: primaryBlue,
        unselectedItemColor: const Color(0xFF98A2B3),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,

        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'SansSerif',
          fontSize: 13
        ),

        unselectedLabelStyle: TextStyle(
          fontFamily: 'SansSerif',
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Akun dan Role',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  // 1. Widget untuk Card Statistik atas
  Widget _buildStatCard(
    String count,
    String title,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias, // Agar efek gelombang tidak keluar border radius
      child: Stack(
        children: [
          // Efek Gelombang Dekorasi di bagian bawah Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textDarkColor,
                        fontFamily: 'SansSerif',
                      ),
                    ),
                    Icon(icon, color: color, size: 28),
                  ],
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SansSerif',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Widget Section Grafik Area
  Widget _buildChartSection(List<UserModel> allUsers) {
    // --- PROSES DATA UNTUK GRAFIK ---
    // Array untuk menampung jumlah pegawai per bulan (indeks 0 = Jan, 1 = Feb, ..., 11 = Des)
    List<double> activeMonthlyCount = List.filled(12, 0.0);
    List<double> inactiveMonthlyCount = List.filled(12, 0.0);

    for (var user in allUsers) {
      try {
        // Ambil data bulan dari string "2026-05-09..." -> diambil angka "05" -> dikonversi ke int
        DateTime parsedDate = DateTime.parse(user.createdAt);
        int monthIndex =
            parsedDate.month - 1; // Mengubah 1-12 menjadi skala indeks 0-11

        if (monthIndex >= 0 && monthIndex < 12) {
          if (user.status.toLowerCase() == 'aktif') {
            activeMonthlyCount[monthIndex] += 1.0;
          } else {
            inactiveMonthlyCount[monthIndex] += 1.0;
          }
        }
      } catch (e) {
        // Menghindari crash jika ada format tanggal dari backend yang corrupt
        print("Error parsing date: $e");
      }
    }

    // Membuat koordinat titik (X, Y) untuk grafik batang garis
    List<FlSpot> activeSpots = [];
    List<FlSpot> inactiveSpots = [];

    for (int i = 0; i < 12; i++) {
      activeSpots.add(FlSpot(i.toDouble(), activeMonthlyCount[i]));
      inactiveSpots.add(FlSpot(i.toDouble(), inactiveMonthlyCount[i]));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F4F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Status Akun Pegawai",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textDarkColor,
                  fontFamily: 'SansSerif',
                ),
              ),
              Row(
                children: [
                  _buildLegendIndicator(
                    const Color(0xFF12B76A),
                    "Aktif",
                  ), // Hijau Sukses
                  const SizedBox(width: 12),
                  _buildLegendIndicator(
                    const Color(0xFF98A2B3),
                    "Non-Aktif",
                  ), // Abu-abu pudar
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- IMPLEMENTASI FL_CHART ---
          SizedBox(
            height: 180, // Tinggi area grafik
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  show: false,
                ), // Sembunyikan garis kotak latar belakang agar clean
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ), // Sembunyikan angka sumbu Y sesuai mockup
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        // Kustomisasi teks sumbu X (Hanya memunculkan singkatan bulan tertentu agar muat di layar HP)
                        switch (value.toInt()) {
                          case 0:
                            return const Text(
                              'Jan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontFamily: 'SansSerif',
                              ),
                            );
                          case 2:
                            return const Text(
                              'Mar',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontFamily: 'SansSerif',
                              ),
                            );
                          case 4:
                            return const Text(
                              'Mei',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontFamily: 'SansSerif',
                              ),
                            );
                          case 6:
                            return const Text(
                              'Jul',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontFamily: 'SansSerif',
                              ),
                            );
                          case 8:
                            return const Text(
                              'Sep',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontFamily: 'SansSerif',
                              ),
                            );
                          case 10:
                            return const Text(
                              'Nov',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontFamily: 'SansSerif',
                              ),
                            );
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ), // Hapus garis border luar chart
                lineBarsData: [
                  // 1. GARIS DATA PEGAWAI AKTIF
                  LineChartBarData(
                    spots: activeSpots,
                    isCurved:
                        true, // Membuat garis melengkung halus sesuai mockup UI/UX
                    color: const Color(0xFF12B76A),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(
                      show: false,
                    ), // Sembunyikan bulatan titik koordinat agar clean
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF12B76A).withOpacity(
                        0.1,
                      ), // Efek gradasi warna pudar di bawah garis
                    ),
                  ),
                  // 2. GARIS DATA PEGAWAI NON-AKTIF
                  LineChartBarData(
                    spots: inactiveSpots,
                    isCurved: true,
                    color: const Color(0xFF98A2B3),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF98A2B3).withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF667085),
            fontFamily: 'SansSerif',
          ),
        ),
      ],
    );
  }

  // 3. Widget Section Kalender Mini
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

  // 4. Widget Card Pegawai khusus Mobile sesuai desain baru
  Widget _buildEmployeeCard({required UserModel user}) {
    bool isAktif = user.status.toLowerCase() == "aktif";

    String displayRole = user.getUtamaRole;

    String displayDate = user.createdAt.length > 10
        ? user.createdAt.substring(0, 10)
        : (user.createdAt.isEmpty ? "-" : user.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F4F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDarkColor,
                    fontFamily: 'SansSerif',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAktif
                      ? const Color(0xFFECFDF3)
                      : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAktif ? "Aktif" : "Non-Aktif",
                  style: TextStyle(
                    color: isAktif
                        ? const Color(0xFF027A48)
                        : const Color(0xFF667085),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SansSerif',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Text(
            user.email,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
              fontFamily: 'SansSerif',
            ),
          ),
          const SizedBox(height: 16),

          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  displayRole,
                  style: const TextStyle(
                    color: Color(0xFF2D62ED),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SansSerif',
                  ),
                ),
              ),
              Text(
                displayDate,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF667085),
                  fontFamily: 'SansSerif',
                ),
              ),
              Text(
                user.nomorIdentitas,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textDarkColor,
                  fontFamily: 'SansSerif',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return FutureBuilder<List<UserModel>>(
      future: UserService.fetchUsers(), // Panggil API satu kali di atas
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Gagal memuat data: ${snapshot.error}",
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'SansSerif',
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Tidak ada data pegawai."));
        }

        // === DATA BEBAS DIOLAH DI SINI ===
        List<UserModel> allUsers = snapshot.data!;

        // Menghitung jumlah admin berdasarkan role dari API
        // Gunakan .where() untuk menyaring data yang cocok lalu hitung panjang (.length) datanya
        int akademikCount = allUsers
            .where(
              (u) =>
                  u.roleId == 2 ||
                  u.roles.any(
                    (r) =>
                        r.idRole == 2 ||
                        r.namaRole.toLowerCase() == "admin_akademik",
                  ),
            )
            .length;

        int pegawaiCount = allUsers
            .where(
              (u) =>
                  u.roleId == 3 ||
                  u.roles.any(
                    (r) =>
                        r.idRole == 3 ||
                        r.namaRole.toLowerCase() == "admin_pegawai",
                  ),
            )
            .length;

        int mahasiswaCount = allUsers
            .where(
              (u) =>
                  u.roleId == 4 ||
                  u.roles.any(
                    (r) =>
                        r.idRole == 4 ||
                        r.namaRole.toLowerCase() == "admin_mahasiswa",
                  ),
            )
            .length;

        int keuanganCount = allUsers
            .where(
              (u) =>
                  u.roleId == 5 ||
                  u.roles.any(
                    (r) =>
                        r.idRole == 5 ||
                        r.namaRole.toLowerCase() == "admin_keuangan",
                  ),
            )
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. GRID STATISTIK CARD (Sekarang Datanya Dinamis!)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    akademikCount.toString(),
                    "Admin Akademik",
                    const Color(0xFF2D62ED),
                    Icons.school,
                  ),
                  _buildStatCard(
                    pegawaiCount.toString(),
                    "Admin Pegawai",
                    const Color(0xFF7A5AF8),
                    Icons.school_outlined,
                  ),
                  _buildStatCard(
                    mahasiswaCount.toString(),
                    "Admin Mahasiswa",
                    const Color(0xFFF04438),
                    Icons.groups,
                  ),
                  _buildStatCard(
                    keuanganCount.toString(),
                    "Admin Keuangan",
                    const Color(0xFF12B76A),
                    Icons.group_add,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. STATUS AKUN PEGAWAI (GRAFIK)
              _buildChartSection(allUsers),
              const SizedBox(height: 24),

              // 3. KALENDER MEI 2026
              _buildCalendarSection(),
              const SizedBox(height: 24),

              // 4. DAFTAR PEGAWAI SECTION
              Text(
                "Daftar Pegawai",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDarkColor,
                  fontFamily: 'SansSerif',
                ),
              ),
              const SizedBox(height: 12),

              // Render List Daftar Pegawai dari data yang sama
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allUsers.length,
                itemBuilder: (context, index) {
                  return _buildEmployeeCard(user: allUsers[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
