import 'package:flutter/material.dart';
import 'package:mobile_kel1/models/user_model.dart';
import 'package:mobile_kel1/services/user_service.dart';

class AkundanroleSuperAdminPage extends StatefulWidget {
  const AkundanroleSuperAdminPage({super.key});

  @override
  State<AkundanroleSuperAdminPage> createState() =>
      _AkundanroleSuperAdminPageState();
}

class _AkundanroleSuperAdminPageState extends State<AkundanroleSuperAdminPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'Terbaru';
  String _selectedRole = 'Semua';
  String _selectedStatus = 'Aktif';

  // Variabel penampung data utama dan data hasil filter search
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Tema Warna sesuai panduan UI/UX
  final Color primaryBlue = const Color(0xFF2D62ED);
  final Color textDarkColor = const Color(0xFF101828);
  final Color greyTextColor = const Color(0xFF667085);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Mengambil data dari Backend sekaligus mengaktifkan fitur pencarian lokal
  Future<void> _loadData() async {
    try {
      final data = await UserService.fetchUsers();
      setState(() {
        _allUsers = data;
        _filteredUsers = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Fungsi pencarian realtime di sisi client (Local Search)
  void _filterSearch(String query) {
    setState(() {
      _filteredUsers = _allUsers
          .where(
            (user) =>
                user.name.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()) ||
                user.nomorIdentitas.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void _applyFilters() {
    List<UserModel> tempUsers = List.from(_allUsers);

    // 1. FILTER BERDASARKAN STATUS
    if (_selectedStatus != 'Semua') {
      tempUsers = tempUsers.where((user) {
        // Mengubah ke huruf kecil semua agar 'Aktif' cocok dengan 'aktif'
        return user.status.toLowerCase() == _selectedStatus.toLowerCase();
      }).toList();
    }

    // 2. FILTER BERDASARKAN HAK AKSES / ROLE
    if (_selectedRole != 'Semua') {
      tempUsers = tempUsers.where((user) {
        // Ambil nama role utama, ubah jadi huruf kecil, dan hapus spasi agar mudah dicocokkan
        String normalizeNamaRole = user.getUtamaRole.toLowerCase().replaceAll(
          ' ',
          '',
        );

        String roleKey = '';
        if (_selectedRole == 'Admin Akademik') roleKey = 'adminakademik';
        if (_selectedRole == 'Admin Pegawai') roleKey = 'adminpegawai';
        if (_selectedRole == 'Admin Mahasiswa') roleKey = 'adminmahasiswa';
        if (_selectedRole == 'Admin Keuangan') roleKey = 'adminkeuangan';
        if (_selectedRole == 'Pegawai') roleKey = 'pegawai';

        // Jika memilih 'Lainnya +', tampilkan yang bukan dari 4 role di atas dan bukan super_admin
        // if (_selectedRole == 'Lainnya') {
        //   return normalizeNamaRole != 'adminakademik' &&
        //       normalizeNamaRole != 'adminpegawai' &&
        //       normalizeNamaRole != 'adminmahasiswa' &&
        //       normalizeNamaRole != 'adminkeuangan' &&
        //       normalizeNamaRole != 'superadmin';
        // }

        return normalizeNamaRole == roleKey;
      }).toList();
    }

    // 3. PENGURUTAN DATA (SORTING)
    if (_selectedSort == 'Terbaru') {
      tempUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_selectedSort == 'Terlama') {
      tempUsers.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (_selectedSort == 'Nama A - Z') {
      tempUsers.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    } else if (_selectedSort == 'Nama Z - A') {
      tempUsers.sort(
        (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
      );
    }

    // Update state untuk memperbarui ListView di layar
    setState(() {
      _filteredUsers = tempUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            "Error: $_errorMessage",
            style: const TextStyle(color: Colors.red, fontFamily: 'SansSerif'),
          ),
        ),
      );
    }

    // Menghitung jumlah per kategori dinamis dari API untuk Card atas
    int akademikCount = _allUsers
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

    int pegawaiCount = _allUsers
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

    int mahasiswaCount = _allUsers
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

    int keuanganCount = _allUsers
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Akun dan Role",
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
              backgroundColor: Colors.grey[300],
              backgroundImage: AssetImage(
                'assets/images/profilSuperAdminS.png',
              ),
              // child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SEARCH BAR & FILTER BUTTON
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterSearch,
                      decoration: InputDecoration(
                        hintText: "Cari Pegawai...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () =>
                      _showFilterBottomSheet(), // Nanti disambung ke layout filtermu
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune_rounded, color: textDarkColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. GRID STATISTIK CARD (Sama seperti dashboard)
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
            const SizedBox(height: 20),

            // 3. TOMBOL TAMBAH PEGAWAI
            // Cari kode ElevatedButton Tambah Pegawai kamu sebelumnya, lalu pasang di properti onPressed:
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    _showAddEmployeeBottomSheet, // Panggil fungsi form di sini!
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Tambah Pegawai +",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'SansSerif',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. DAFTAR PEGAWAI HEADER
            Row(
              children: [
                Text(
                  "Daftar Pegawai",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDarkColor,
                    fontFamily: 'SansSerif',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D5DD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _filteredUsers.length.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SansSerif',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. LIST CARD MANAGEMENT ACCOUNTE
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                return _buildActionEmployeeCard(_filteredUsers[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CARD DENGAN TOMBOL AKSI AKUN ---
  Widget _buildActionEmployeeCard(UserModel user) {
    bool isAktif = user.status.toLowerCase() == "aktif";

    // Langsung ambil string text rapi yang dihasilkan oleh getter model
    String displayRole = user.getUtamaRole;

    String displayDate = user.createdAt.length > 10
        ? user.createdAt.substring(0, 10)
        : user.createdAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F4F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama & Status Badge
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

          // Nomor Identitas pengganti NIP
          Text(
            "ID: ${user.nomorIdentitas}",
            style: TextStyle(
              fontSize: 13,
              color: greyTextColor,
              fontFamily: 'SansSerif',
            ),
          ),
          const SizedBox(height: 12),

          Divider(color: Colors.grey[100], thickness: 1),
          const SizedBox(height: 12),

          // Email & Tanggal Terdaftar Info
          Row(
            children: [
              const Icon(
                Icons.mail_outline_rounded,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: greyTextColor,
                    fontFamily: 'SansSerif',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "$displayDate | ${user.nomorIdentitas}",
                style: TextStyle(
                  fontSize: 12,
                  color: greyTextColor,
                  fontFamily: 'SansSerif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // BARIS ACTION BUTTONS (Status Toggle, Edit, Delete)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge Singkatan Hak Akses
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
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SansSerif',
                  ),
                ),
              ),

              // Kumpulan 3 Tombol Aksi di Kanan
              Row(
                children: [
                  // 1. Tombol Toggle Status (Aktif / Non-Aktif)
                  _buildIconButton(
                    icon: isAktif
                        ? Icons.block_outlined
                        : Icons.check_circle_outline_rounded,
                    iconColor: isAktif
                        ? const Color(0xFF667085)
                        : const Color(0xFF12B76A),
                    bgColor: isAktif
                        ? const Color(0xFFF2F4F7)
                        : const Color(0xFFECFDF3),
                    onTap: () => _showStatusConfirmationDialog(
                      user,
                    ), // Akan dikonekkan ke dialogmu
                  ),
                  const SizedBox(width: 8),

                  // 2. Tombol Edit (Pensil)
                  _buildIconButton(
                    icon: Icons.edit_outlined,
                    iconColor: const Color(0xFF344054),
                    bgColor: const Color(0xFFF2F4F7),
                    onTap: () => _showEditEmployeeBottomSheet(
                      user.id,
                    ), // Akan dikonekkan ke form edit
                  ),
                  const SizedBox(width: 8),

                  // 3. Tombol Hapus (Sampah)
                  // _buildIconButton(
                  //   icon: Icons.delete_outline_rounded,
                  //   iconColor: const Color(0xFFF04438),
                  //   bgColor: const Color(0xFFFEF3F2),
                  //   onTap: () => print(
                  //     "Konfirmasi Hapus Akun: ${user.id}",
                  //   ), // Akan dikonekkan ke dialog hapus
                  // ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Desain dasar tombol bundar kecil untuk aksi
  Widget _buildIconButton({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  // Statistik Top Card Helper
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
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
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
                    Icon(icon, color: color, size: 26),
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Fungsi pembantu pembuat tombol opsi pilhan filter
            Widget buildFilterChip({
              required String label,
              required bool isSelected,
              required VoidCallback onTap,
            }) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected
                          ? const Color(0xFFEBF2FE)
                          : Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? primaryBlue
                            : const Color(0xFFD0D5DD),
                        width: isSelected ? 1.5 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? primaryBlue
                            : const Color(0xFF344054),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 13,
                        fontFamily: 'SansSerif',
                      ),
                    ),
                  ),
                ),
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Garis penanda handle geser atas
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filter & Urutkan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDarkColor,
                          fontFamily: 'SansSerif',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.grey,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // BAGIAN 1: URUTKAN BERDASARKAN
                  Text(
                    "Urutkan Berdasarkan",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textDarkColor,
                      fontFamily: 'SansSerif',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      buildFilterChip(
                        label: "Terbaru",
                        isSelected: _selectedSort == 'Terbaru',
                        onTap: () =>
                            setModalState(() => _selectedSort = 'Terbaru'),
                      ),
                      buildFilterChip(
                        label: "Terlama",
                        isSelected: _selectedSort == 'Terlama',
                        onTap: () =>
                            setModalState(() => _selectedSort = 'Terlama'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildFilterChip(
                        label: "Nama A - Z",
                        isSelected: _selectedSort == 'Nama A - Z',
                        onTap: () =>
                            setModalState(() => _selectedSort = 'Nama A - Z'),
                      ),
                      buildFilterChip(
                        label: "Nama Z - A",
                        isSelected: _selectedSort == 'Nama Z - A',
                        onTap: () =>
                            setModalState(() => _selectedSort = 'Nama Z - A'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BAGIAN 2: FILTER HAK AKSES
                  Text(
                    "Filter Hak Akses",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textDarkColor,
                      fontFamily: 'SansSerif',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      buildFilterChip(
                        label: "Semua",
                        isSelected: _selectedRole == 'Semua',
                        onTap: () =>
                            setModalState(() => _selectedRole = 'Semua'),
                      ),
                      buildFilterChip(
                        label: "Admin Akademik",
                        isSelected: _selectedRole == 'Admin Akademik',
                        onTap: () => setModalState(
                          () => _selectedRole = 'Admin Akademik',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildFilterChip(
                        label: "Admin Pegawai",
                        isSelected: _selectedRole == 'Admin Pegawai',
                        onTap: () => setModalState(
                          () => _selectedRole = 'Admin Pegawai',
                        ),
                      ),
                      buildFilterChip(
                        label: "Admin Mahasiswa",
                        isSelected: _selectedRole == 'Admin Mahasiswa',
                        onTap: () => setModalState(
                          () => _selectedRole = 'Admin Mahasiswa',
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      buildFilterChip(
                        label: "Admin Keuangan",
                        isSelected: _selectedRole == 'Admin Keuangan',
                        onTap: () => setModalState(
                          () => _selectedRole = 'Admin Keuangan',
                        ),
                      ),
                      buildFilterChip(
                        label: "Pegawai",
                        isSelected: _selectedRole == 'Pegawai',
                        onTap: () =>
                            setModalState(() => _selectedRole = 'Pegawai'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BAGIAN 3: STATUS AKUN
                  Text(
                    "Status Akun",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textDarkColor,
                      fontFamily: 'SansSerif',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      buildFilterChip(
                        label: "Aktif",
                        isSelected: _selectedStatus == 'Aktif',
                        onTap: () =>
                            setModalState(() => _selectedStatus = 'Aktif'),
                      ),
                      buildFilterChip(
                        label: "Non-Aktif",
                        isSelected: _selectedStatus == 'nonaktif',
                        onTap: () =>
                            setModalState(() => _selectedStatus = 'nonaktif'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // TOMBOL ATUR ULANG & TERAPKAN
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedSort = 'Terbaru';
                              _selectedRole = 'Semua';
                              _selectedStatus = 'Aktif';
                            });
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFD0D5DD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Atur Ulang",
                            style: TextStyle(
                              color: Color(0xFF344054),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _applyFilters(); // Jalankan penyaringan data
                            Navigator.pop(context); // Tutup bottom sheet
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Terapkan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddEmployeeBottomSheet() {
    // Controller untuk menangkap isi teks input
    final TextEditingController nipController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    // Variabel penampung nilai Dropdown
    String?
    selectedHakAkses; // 'Admin Akademik', 'Admin Pegawai', dan lain-lain
    String? selectedStatus; // 'Aktif', 'Non-Aktif'

    // Map pembantu untuk mengubah teks Hak Akses menjadi ID Role sesuai spesifikasi database kamu
    final Map<String, int> roleMap = {
      'Admin Akademik': 2,
      'Admin Pegawai': 3,
      'Admin Mahasiswa': 4,
      'Admin Keuangan': 5,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Membuat tinggi modal fleksibel mengikuti keyboard
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Helper Pembuat Dekorasi Input Field agar terlihat rapi dan seragam
            Widget buildInputField({
              required String label,
              required String hint,
              required TextEditingController controller,
              bool isPassword = false,
            }) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: label,
                        style: TextStyle(
                          color: textDarkColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'SansSerif',
                        ),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller,
                      obscureText: isPassword,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 14,
                          fontFamily: 'SansSerif',
                        ),
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
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D5DD),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    20, // Otomatis naik saat keyboard muncul
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Batang Handle Top Bottom Sheet
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tambah Pegawai",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDarkColor,
                            fontFamily: 'SansSerif',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.grey,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Elemen Form Sesuai Gambar Mockup
                    buildInputField(
                      label: "NIP",
                      hint: "Masukkan NIP",
                      controller: nipController,
                    ),
                    buildInputField(
                      label: "Nama Lengkap",
                      hint: "Masukkan nama lengkap",
                      controller: nameController,
                    ),
                    buildInputField(
                      label: "Nama Pengguna",
                      hint: "Masukkan nama pengguna",
                      controller: usernameController,
                    ),
                    buildInputField(
                      label: "Alamat Email",
                      hint: "Masukkan email",
                      controller: emailController,
                    ),

                    // Baris Dropdown (Jenis Hak Akses & Status)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          // Dropdown Hak Akses
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: "Jenis Hak Akses",
                                    style: TextStyle(
                                      color: textDarkColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      fontFamily: 'SansSerif',
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontFamily: 'SansSerif',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFD0D5DD),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedHakAkses,
                                      hint: const Text(
                                        "Pilih jenis hak akses",
                                        style: TextStyle(
                                          color: Color(0xFF98A2B3),
                                          fontSize: 13,
                                          fontFamily: 'SansSerif',
                                        ),
                                      ),
                                      isExpanded: true,
                                      items: roleMap.keys.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'SansSerif',
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) => setModalState(
                                        () => selectedHakAkses = newValue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Dropdown Status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Status",
                                  style: TextStyle(
                                    color: textDarkColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    fontFamily: 'SansSerif',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFD0D5DD),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedStatus,
                                      hint: const Text(
                                        "Pilih status",
                                        style: TextStyle(
                                          color: Color(0xFF98A2B3),
                                          fontSize: 13,
                                          fontFamily: 'SansSerif',
                                        ),
                                      ),
                                      isExpanded: true,
                                      items: <String>['Aktif', 'Non-Aktif'].map(
                                        (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'SansSerif',
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                      onChanged: (newValue) => setModalState(
                                        () => selectedStatus = newValue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Input Password & Konfirmasi Password
                    buildInputField(
                      label: "Kata Sandi",
                      hint: "Masukkan kata sandi",
                      controller: passwordController,
                      isPassword: true,
                    ),
                    buildInputField(
                      label: "Konfirmasi Sandi",
                      hint: "Masukkan kembali kata sandi",
                      controller: confirmPasswordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),

                    // Tombol Aksi Batal dan Tambah
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Color(0xFF344054),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            // 1. Validasi Input Kosong
                            if (nipController.text.isEmpty ||
                                nameController.text.isEmpty ||
                                emailController.text.isEmpty ||
                                selectedHakAkses == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Harap isi semua kolom bertanda bintang (*)",
                                  ),
                                ),
                              );
                              return;
                            }
                            // 2. Validasi Kesamaan Password
                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Konfirmasi kata sandi tidak cocok!",
                                  ),
                                ),
                              );
                              return;
                            }

                            // Jalankan fungsi API POST
                            bool success = await UserService.registerUser(
                              name: nameController.text.trim(),
                              username: usernameController.text.trim(),
                              nomorIdentitas: nipController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text,
                              roleId: roleMap[selectedHakAkses]!,
                              status: (selectedStatus ?? 'Aktif').toLowerCase(),
                            );

                            if (success) {
                              Navigator.pop(context); // Tutup bottom sheet form
                              _loadData(); // Memicu refresh daftar pegawai secara real-time di halaman utama
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Pegawai baru berhasil ditambahkan!",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Gagal mendaftarkan pegawai. Periksa koneksi/email unik.",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Tambah",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showStatusConfirmationDialog(UserModel user) {
    bool isCurrentAktif = user.status.toLowerCase() == "aktif";
    String targetStatus = isCurrentAktif ? "nonaktif" : "aktif";

    showDialog(
      context: context,
      barrierDismissible: false, // User wajib memilih Batal atau Eksekusi
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. INDIKATOR IKON BULAT DI ATAS
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isCurrentAktif
                        ? const Color(0xFFFEF3F2)
                        : const Color(0xFFECFDF3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrentAktif
                          ? const Color(0xFFFECDCA)
                          : const Color(0xFFABEFC6),
                      width: 4,
                    ),
                  ),
                  child: Icon(
                    isCurrentAktif
                        ? Icons.person_off_outlined
                        : Icons.person_add_alt_1_outlined,
                    color: isCurrentAktif
                        ? const Color(0xFFF04438)
                        : const Color(0xFF12B76A),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),

                // 2. JUDUL DIALOG
                Text(
                  isCurrentAktif ? "Non-aktifkan Akun?" : "Aktifkan Akun?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDarkColor,
                    fontFamily: 'SansSerif',
                  ),
                ),
                const SizedBox(height: 12),

                // 3. DESKRIPSI TEKS DENGAN BOLD PADA NAMA USER
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF475467),
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'SansSerif',
                    ),
                    children: [
                      const TextSpan(text: "Akun "),
                      TextSpan(
                        text: user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textDarkColor,
                          fontFamily: 'SansSerif',
                        ),
                      ),
                      TextSpan(
                        text: isCurrentAktif
                            ? " akan dinonaktifkan. Pegawai ini tidak dapat login, namun datanya tetap aman."
                            : " akan diaktifkan kembali. Pegawai kini dapat login dan mengakses fitur sistem.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. TOMBOL AKSI SEJAJAR (BATAL & EKSEKUSI)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            color: Color(0xFF344054),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SansSerif',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Jalankan request ke API Backend
                          bool success = await UserService.updateUserStatus(
                            user.id,
                            targetStatus,
                          );

                          if (success) {
                            Navigator.pop(context); // Tutup dialog konfirmasi
                            _loadData(); // Memuat ulang list agar status terupdate realtime di layar

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Status akun ${user.name} berhasil diperbarui!",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Gagal mengubah status akun. Coba lagi nanti.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCurrentAktif
                              ? const Color(0xFF344054)
                              : primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isCurrentAktif ? "Non-aktifkan" : "Aktifkan",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SansSerif',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditEmployeeBottomSheet(int userId) async {
    // Tampilkan loading spinner tipis sementara data di-fetch dari server
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Ambil data detail terbaru dari server
    UserModel? userDetail = await UserService.fetchUserDetail(userId);

    // Tutup spinner loading setelah data didapatkan
    Navigator.pop(context);

    if (userDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengambil detail data pegawai"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Daftarkan controller dan set nilai awal dari database
    final TextEditingController nipController = TextEditingController(
      text: userDetail.nomorIdentitas,
    );
    final TextEditingController nameController = TextEditingController(
      text: userDetail.name,
    );
    final TextEditingController usernameController = TextEditingController(
      text: userDetail.username,
    );
    final TextEditingController emailController = TextEditingController(
      text: userDetail.email,
    );

    // Map pembantu nama role ke ID database
    final Map<String, int> roleMap = {
      'Admin Akademik': 2,
      'Admin Pegawai': 3,
      'Admin Mahasiswa': 4,
      'Admin Keuangan': 5,
    };

    // Balikkan ID role dari database menjadi teks Dropdown
    String? selectedHakAkses;
    roleMap.forEach((key, value) {
      if (value == userDetail.roleId) {
        selectedHakAkses = key;
      }
    });

    // Set nilai awal status (Kapitalisasi huruf pertama agar sesuai pilihan dropdown)
    String? selectedStatus = userDetail.status.toLowerCase() == 'aktif'
        ? 'Aktif'
        : 'Non-Aktif';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Helper input field kustom
            Widget buildInputField({
              required String label,
              required String hint,
              required TextEditingController controller,
            }) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: label,
                        style: TextStyle(
                          color: textDarkColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'SansSerif',
                        ),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 14,
                          fontFamily: 'SansSerif',
                        ),
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
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D5DD),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar atas
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Edit Pegawai",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDarkColor,
                            fontFamily: 'SansSerif',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.grey,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Kolom Input Atas
                    buildInputField(
                      label: "NIP",
                      hint: "Masukkan NIP",
                      controller: nipController,
                    ),
                    buildInputField(
                      label: "Nama Lengkap",
                      hint: "Masukkan nama lengkap",
                      controller: nameController,
                    ),
                    buildInputField(
                      label: "Nama Pengguna",
                      hint: "Masukkan nama pengguna",
                      controller: usernameController,
                    ),

                    // Baris Fleksibel: Alamat Email & Status Berdampingan
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kolom Email
                          Expanded(
                            flex: 2,
                            child: buildInputField(
                              label: "Alamat Email",
                              hint: "Masukkan email",
                              controller: emailController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Kolom Dropdown Status
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Status",
                                    style: TextStyle(
                                      color: textDarkColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      fontFamily: 'SansSerif',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    height: 46,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFD0D5DD),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedStatus,
                                        isExpanded: true,
                                        items: <String>['Aktif', 'Non-Aktif']
                                            .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'SansSerif',
                                                  ),
                                                ),
                                              );
                                            })
                                            .toList(),
                                        onChanged: (newValue) => setModalState(
                                          () => selectedStatus = newValue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dropdown Jenis Hak Akses Lebar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Jenis Hak Akses",
                            style: TextStyle(
                              color: textDarkColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD0D5DD),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedHakAkses,
                                isExpanded: true,
                                items: roleMap.keys.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'SansSerif',
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) => setModalState(
                                  () => selectedHakAkses = newValue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Tombol Aksi Simpan & Batal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Color(0xFF344054),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (nipController.text.isEmpty ||
                                nameController.text.isEmpty ||
                                emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Field wajib tidak boleh kosong!",
                                  ),
                                ),
                              );
                              return;
                            }

                            bool success = await UserService.updateUserDetail(
                              userId: userId,
                              name: nameController.text.trim(),
                              username: usernameController.text.trim(),
                              nomorIdentitas: nipController.text.trim(),
                              email: emailController.text.trim(),
                              roleId: roleMap[selectedHakAkses]!,
                              status: (selectedStatus ?? 'Aktif')
                                  .toLowerCase()
                                  .replaceAll(
                                    '-',
                                    '',
                                  ), // Ubah 'Non-Aktif' jadi 'nonaktif'
                            );

                            if (success) {
                              Navigator.pop(context); // Tutup bottom sheet
                              _loadData(); // Segarkan list UI utama secara realtime
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Data pegawai berhasil diperbarui!",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Gagal memperbarui data pegawai.",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Simpan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
