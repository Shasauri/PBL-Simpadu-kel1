import 'package:flutter/material.dart';
import '../../services/academic_service.dart';

class KelolaKelasPage extends StatefulWidget {
  final int idKelas;

  const KelolaKelasPage({super.key, required this.idKelas});

  @override
  State<KelolaKelasPage> createState() => _KelolaKelasPageState();
}

class _KelolaKelasPageState extends State<KelolaKelasPage> {
  Map<String, dynamic>? _kelasInfo;
  List<dynamic> _mahasiswaList = [];
  List<dynamic> _filteredMahasiswa = [];

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final infoData =
        await AcademicService.fetchDetailKelolaKelas(widget.idKelas);
    final mhsData = await AcademicService.fetchMahasiswaKelas(widget.idKelas);

    setState(() {
      if (infoData != null && infoData.containsKey('kelas')) {
        _kelasInfo = infoData['kelas'];
      } else {
        _kelasInfo = infoData;
      }
      _mahasiswaList = mhsData;
      _filteredMahasiswa = mhsData;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMahasiswa = _mahasiswaList.where((item) {
        final mhsObj = item['mahasiswa'] ?? {};
        final nama = (mhsObj['name'] ?? '').toString().toLowerCase();
        final nim =
            (item['nim'] ?? mhsObj['nomor_identitas'] ?? '')
                .toString()
                .toLowerCase();
        return nama.contains(query) || nim.contains(query);
      }).toList();
    });
  }

  void _AksiKonfirmasiHapus(int idMahasiswaMk, String namaMhs) {
    final String namaKelas = _kelasInfo?['nama_kelas'] ?? _kelasInfo?['kode_kelas'] ?? "kelas ini";
    final String nimMhs = _mahasiswaList.firstWhere(
      (item) => (item['id_mahasiswa_mk'] ?? item['id']) == idMahasiswaMk,
      orElse: () => {},
    )?['nim'] ?? _mahasiswaList.firstWhere(
      (item) => (item['id_mahasiswa_mk'] ?? item['id']) == idMahasiswaMk,
      orElse: () => {},
    )?['mahasiswa']?['nomor_identitas'] ?? '';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ICON TRASH
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE4E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFF04438),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              // TITLE
              const Text(
                "Hapus Mahasiswa dari Kelas?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828),
                  fontFamily: "SansSerif",
                ),
              ),
              const SizedBox(height: 10),
              // BODY TEXT
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF667085),
                    height: 1.5,
                    fontFamily: "SansSerif",
                  ),
                  children: [
                    const TextSpan(text: "Apakah Anda yakin ingin menghapus "),
                    TextSpan(
                      text: nimMhs.isNotEmpty
                          ? "$namaMhs ($nimMhs)"
                          : namaMhs,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                        fontFamily: "SansSerif",
                      ),
                    ),
                    const TextSpan(text: " dari "),
                    TextSpan(
                      text: "Kelas $namaKelas",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                        fontFamily: "SansSerif",
                      ),
                    ),
                    const TextSpan(text: "?"),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // WARNING TEXT
              const Text(
                "Data dan rekap absensi mahasiswa ini di kelas terkait akan terhapus secara permanen.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF98A2B3),
                  height: 1.5,
                  fontFamily: "SansSerif",
                ),
              ),
              const SizedBox(height: 20),
              // BUTTONS ROW
              Row(
                children: [
                  // BATAL
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Batal",
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
                  // YA HAPUS
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF04438),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() => _isLoading = true);

                          final success = await AcademicService
                              .deleteMahasiswaDariKelas(idMahasiswaMk);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Mahasiswa berhasil dikeluarkan dari kelas.",
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            _loadData();
                          } else {
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Gagal mengeluarkan mahasiswa."),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Ya, Hapus Data",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "SansSerif",
                            fontSize: 11,
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
    );
  }

  // Helper: generate avatar color from name
  Color _avatarColor(String name) {
    const colors = [
      Color(0xFFEFF4FF),
      Color(0xFFF0FDF4),
      Color(0xFFFFF7ED),
      Color(0xFFFDF4FF),
      Color(0xFFEFF6FF),
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  Color _avatarTextColor(String name) {
    const colors = [
      Color(0xFF2D62ED),
      Color(0xFF027A48),
      Color(0xFFB54708),
      Color(0xFF6941C6),
      Color(0xFF175CD3),
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final String namaKelas = _kelasInfo?['nama_kelas'] ?? "-";
    final String kodeKelas = _kelasInfo?['kode_kelas'] ?? "-";
    final String namaProdi = _kelasInfo?['prodi']?['nama_prodi'] ?? "-";
    final int kapasitas = _kelasInfo?['kapasitas_mahasiswa'] ?? 0;
    final String taLabel =
        _kelasInfo?['tahun_akademik']?['tahun_akademik'] ?? '-';
    final String semester =
        _kelasInfo?['tahun_akademik']?['semester'] ?? '';
    final String taFull =
        semester.isNotEmpty ? "$taLabel ($semester)" : taLabel;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "Daftar Mahasiswa",
          style: TextStyle(
            color: Color(0xFF101828),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: "SansSerif",
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // HERO HEADER CARD - BLUE GRADIENT
                if (_kelasInfo != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D62ED), Color(0xFF5B8DF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kelas $kodeKelas",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "SansSerif",
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$namaKelas • $namaProdi",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85),
                            fontFamily: "SansSerif",
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // JUMLAH MAHASISWA CHIP
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_outline_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${_mahasiswaList.length} / $kapasitas Mahasiswa",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "SansSerif",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // TAHUN AKADEMIK CHIP
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.menu_book_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    taFull,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "SansSerif",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari NIM / Nama...",
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
                ),
                const SizedBox(height: 12),

                // LIST VIEW MAHASISWA
                Expanded(
                  child: _filteredMahasiswa.isEmpty
                      ? const Center(
                          child: Text("Tidak ada mahasiswa di kelas ini."),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredMahasiswa.length,
                          itemBuilder: (context, index) {
                            final item = _filteredMahasiswa[index];
                            final mhs = item['mahasiswa'] ?? {};
                            final String namaMhs =
                                mhs['name'] ?? "Tidak Diketahui";
                            final String nimMhs =
                                item['nim'] ?? mhs['nomor_identitas'] ?? "-";
                            final String emailMhs = mhs['email'] ?? "-";
                            final String statusMhs =
                                (mhs['status'] ?? item['status'] ?? 'aktif')
                                    .toString()
                                    .toLowerCase();
                            final bool isMhsAktif = statusMhs == 'aktif';

                            final String initial = namaMhs.isNotEmpty
                                ? namaMhs[0].toUpperCase()
                                : "M";
                            final Color avBg = _avatarColor(namaMhs);
                            final Color avText = _avatarTextColor(namaMhs);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFEAECF0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  12,
                                  14,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // AVATAR
                                        CircleAvatar(
                                          backgroundColor: avBg,
                                          radius: 22,
                                          child: Text(
                                            initial,
                                            style: TextStyle(
                                              color: avText,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              fontFamily: "SansSerif",
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // NAME + NIM + EMAIL
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    namaMhs,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: "SansSerif",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF101828),
                                                    ),
                                                  ),
                                                  // STATUS BADGE
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isMhsAktif
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
                                                      isMhsAktif
                                                          ? "Aktif"
                                                          : "Non-Aktif",
                                                      style: TextStyle(
                                                        fontFamily: "SansSerif",
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isMhsAktif
                                                            ? const Color(
                                                                0xFF027A48,
                                                              )
                                                            : const Color(
                                                                0xFF667085,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "NIM: $nimMhs",
                                                style: const TextStyle(
                                                  fontFamily: "SansSerif",
                                                  fontSize: 12,
                                                  color: Color(0xFF667085),
                                                ),
                                              ),
                                              Text(
                                                emailMhs,
                                                style: const TextStyle(
                                                  fontFamily: "SansSerif",
                                                  fontSize: 11,
                                                  color: Color(0xFF98A2B3),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // KELUARKAN BUTTON - right-aligned
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFFFF1F3),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 7,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        onPressed: () => _AksiKonfirmasiHapus(
                                          item['id_mahasiswa_mk'] ?? item['id'],
                                          namaMhs,
                                        ),
                                        icon: const Icon(
                                          Icons.person_remove_outlined,
                                          size: 15,
                                          color: Color(0xFFE31B54),
                                        ),
                                        label: const Text(
                                          "Keluarkan",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: "SansSerif",
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFE31B54),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // FOOTER COUNT
                if (_filteredMahasiswa.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    child: Center(
                      child: Text(
                        "Menampilkan ${_filteredMahasiswa.length} dari total ${_mahasiswaList.length} mahasiswa",
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: "SansSerif",
                          color: Color(0xFF98A2B3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}