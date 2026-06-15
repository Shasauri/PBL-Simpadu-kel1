import 'package:flutter/material.dart';
import '../../services/academic_service.dart';

class DosenPengajarPage extends StatefulWidget {
  const DosenPengajarPage({super.key});

  @override
  State<DosenPengajarPage> createState() => _DosenPengajarPageState();
}

class _DosenPengajarPageState extends State<DosenPengajarPage> {
  List<dynamic> _dosenList = [];
  List<dynamic> _filteredDosenList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBebanMengajar();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBebanMengajar() async {
    setState(() => _isLoading = true);
    try {
      final data = await AcademicService.fetchBebanMengajarDosen();
      if (mounted) {
        setState(() {
          _dosenList = data;
          _filteredDosenList = data;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDosenList = _dosenList.where((item) {
        final dosen = item['dosen'] ?? {};
        final namaDosen = (dosen['name'] ?? '').toString().toLowerCase();
        final nomorIdentitas = (dosen['nomor_identitas'] ?? '')
            .toString()
            .toLowerCase();

        final List<dynamic> mkList = item['mata_kuliah'] ?? [];
        final cocokMataKuliah = mkList.any(
          (mk) =>
              (mk['nama_mk'] ?? '').toString().toLowerCase().contains(query),
        );

        return namaDosen.contains(query) ||
            nomorIdentitas.contains(query) ||
            cocokMataKuliah;
      }).toList();
    });
  }

  // ==================== FORM BOTTOM SHEET: TAMBAH DOSEN PENGAJAR ====================
  void _openTambahDosenBottomSheet() async {
    setState(() => _isLoading = true);

    // Load opsi awal untuk dropdown menu
    List<dynamic> listTA = [];
    List<dynamic> listDosenRaw = [];

    try {
      listTA = await AcademicService.fetchTahunAkademikAktif();
      listDosenRaw = await AcademicService.fetchAllDosenRaw();
    } finally {
      // Pastikan loading SELALU dimatikan meskipun terjadi error atau widget unmounted
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;

    // State penampung di dalam modal form
    int? selectedTaId;
    int? selectedDosenId;

    Map<String, dynamic>? selectedMataKuliah;
    Map<String, dynamic>? selectedKelas;

    List<dynamic> poolMataKuliah = [];
    List<dynamic> poolKelas = [];

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
                    const Text(
                      "Tambah Dosen Pengajar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DROPDOWN 1: TAHUN AKADEMIK
                    const Text(
                      "Tahun Akademik",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
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
                        ),
                      ),
                      items: listTA.map((ta) {
                        return DropdownMenuItem<int>(
                          value: ta['id'],
                          child: Text(
                            ta['tahun_akademik'] ?? "-",
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) async {
                        setModalState(() {
                          selectedTaId = val;
                          selectedMataKuliah = null;
                          selectedKelas = null;
                        });
                        if (val != null) {
                          // Fetch data relasional MK dan Kelas menyesuaikan filter Tahun Akademik
                          final mkRes =
                              await AcademicService.fetchMataKuliahByTA(val);
                          final kelasRes = await AcademicService.fetchKelasByTA(
                            val,
                          );
                          setModalState(() {
                            poolMataKuliah = mkRes;
                            poolKelas = kelasRes;
                          });
                        }
                      },
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

                    // DROPDOWN 2: PILIH DOSEN PENGAJAR
                    const Text(
                      "Pilih Dosen Pengajar",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: selectedDosenId,
                      hint: const Text(
                        "Pilih Dosen",
                        style: TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 14,
                        ),
                      ),
                      items: listDosenRaw.map((dsn) {
                        return DropdownMenuItem<int>(
                          value: dsn['id'],
                          child: Text(
                            "${dsn['name']} (${dsn['nomor_identitas'] ?? '-'})",
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setModalState(() => selectedDosenId = val),
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

                    // FITUR SEARCH & SELECT: MATA KULIAH
                    const Text(
                      "Mata Kuliah",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Autocomplete<Map<String, dynamic>>(
                      displayStringForOption: (option) =>
                          option['nama_mk'] ?? "",
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (selectedTaId == null) return const Iterable.empty();
                        return poolMataKuliah.where((option) {
                          return option['nama_mk']
                              .toString()
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        }).cast<Map<String, dynamic>>();
                      },
                      onSelected: (Map<String, dynamic> selection) {
                        setModalState(() => selectedMataKuliah = selection);
                      },
                      fieldViewBuilder:
                          (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              enabled: selectedTaId != null,
                              decoration: InputDecoration(
                                hintText: selectedTaId == null
                                    ? "Pilih Tahun Akademik Terlebih Dahulu"
                                    : "Ketik untuk mencari mata kuliah...",
                                hintStyle: const TextStyle(
                                  color: Color(0xFF98A2B3),
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                    ),
                    if (selectedMataKuliah != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Terpilih: ${selectedMataKuliah!['nama_mk']} (${selectedMataKuliah!['sks']} SKS)",
                        style: const TextStyle(
                          color: Color(0xFF2D62ED),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // FITUR SEARCH & SELECT: KELAS
                    const Text(
                      "Pilih Kelas",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Autocomplete<Map<String, dynamic>>(
                      displayStringForOption: (option) =>
                          option['nama_kelas'] ?? "",
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (selectedTaId == null) return const Iterable.empty();
                        return poolKelas.where((option) {
                          final namaKls = option['nama_kelas']
                              .toString()
                              .toLowerCase();
                          final kodeKls = option['kode_kelas']
                              .toString()
                              .toLowerCase();
                          final query = textEditingValue.text.toLowerCase();
                          return namaKls.contains(query) ||
                              kodeKls.contains(query);
                        }).cast<Map<String, dynamic>>();
                      },
                      onSelected: (Map<String, dynamic> selection) {
                        setModalState(() => selectedKelas = selection);
                      },
                      fieldViewBuilder:
                          (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              enabled: selectedTaId != null,
                              decoration: InputDecoration(
                                hintText: selectedTaId == null
                                    ? "Pilih Tahun Akademik Terlebih Dahulu"
                                    : "Ketik untuk mencari kelas (contoh: TI-6A)...",
                                hintStyle: const TextStyle(
                                  color: Color(0xFF98A2B3),
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                    ),
                    if (selectedKelas != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Terpilih: ${selectedKelas!['nama_kelas']} - ${selectedKelas!['prodi']?['nama_prodi'] ?? ''}",
                        style: const TextStyle(
                          color: Color(0xFF2D62ED),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),

                    // TOMBOL SUBMIT SIMPAN DATA DOSEN
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
                          print("selectedTaId: $selectedTaId");
  print("selectedDosenId: $selectedDosenId");
  print("selectedMataKuliah: $selectedMataKuliah");
  print("selectedKelas: $selectedKelas");
                          if (selectedTaId == null ||
                              selectedDosenId == null ||
                              selectedMataKuliah == null ||
                              selectedKelas == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Harap lengkapi semua isian formulir!",
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context);

                          final int idKelasDiterget = selectedKelas!['id'];
                          final bodyPayload = {
                            "mata_kuliah_id": selectedMataKuliah!['id_mk'],
                            "dosen_id": selectedDosenId,
                            "tahun_akademik_id": selectedTaId,
                          };

                          bool success = false;
                          try {
                            setState(() => _isLoading = true);
                            success = await AcademicService.assignDosenKeKelas(
                              idKelasDiterget,
                              bodyPayload,
                            );
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }

                          if (!mounted) return;

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Sukses mendistribusikan dosen pengajar ke kelas!",
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            _loadBebanMengajar();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Gagal menambahkan beban mengajar dosen.",
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Simpan Data Dosen",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
          "Daftar Dosen",
          style: TextStyle(
            color: Color(0xFF101828),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SEARCH BAR
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari nama dosen, NIDN, atau mata kuliah...",
                      hintStyle: const TextStyle(
                        color: Color(0xFF98A2B3),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF667085),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF2D62ED),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // TOMBOL TAMBAH DOSEN (Sesuai Desain Buat Dosen 1.png)
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
                      onPressed: _openTambahDosenBottomSheet,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Tambah Dosen",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // LIST CARD BEBAN MENGAJAR DOSEN
                  Expanded(
                    child: _filteredDosenList.isEmpty
                        ? const Center(
                            child: Text("Data dosen tidak ditemukan."),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadBebanMengajar,
                            child: ListView.builder(
                              itemCount: _filteredDosenList.length,
                              itemBuilder: (context, index) {
                                final item = _filteredDosenList[index];
                                final dosen = item['dosen'] ?? {};
                                final List<dynamic> mataKuliahList =
                                    item['mata_kuliah'] ?? [];
                                final String status =
                                    dosen['status'] ?? 'nonaktif';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFEAECF0),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: const Color(
                                              0xFFEFF4FF,
                                            ),
                                            radius: 22,
                                            child: Text(
                                              (dosen['name'] ?? 'D')[0]
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Color(0xFF2D62ED),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dosen['name'] ?? "-",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF101828),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "Identitas/NIDN: ${dosen['nomor_identitas'] ?? '-'}",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF667085),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: status == 'aktif'
                                                  ? const Color(0xFFECFDF3)
                                                  : const Color(0xFFFEF3F2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              status == 'aktif'
                                                  ? "Aktif"
                                                  : "Non-Aktif",
                                              style: TextStyle(
                                                color: status == 'aktif'
                                                    ? const Color(0xFF027A48)
                                                    : const Color(0xFFB42318),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        dosen['email'] ?? "-",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF98A2B3),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        child: Divider(
                                          height: 1,
                                          color: Color(0xFFF2F4F7),
                                        ),
                                      ),
                                      const Text(
                                        "Beban Mata Kuliah Mengajar:",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF344054),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      mataKuliahList.isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.only(top: 4),
                                              child: Text(
                                                "Belum ada beban mengajar.",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF98A2B3),
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: mataKuliahList.length,
                                              itemBuilder: (context, mkIndex) {
                                                final mk =
                                                    mataKuliahList[mkIndex];
                                                final kelas = mk['kelas'] ?? {};
                                                final prodi = mk['prodi'] ?? {};
                                                final ta =
                                                    mk['tahun_akademik'] ?? {};

                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 6,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFF9FAFB,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFFEAECF0,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              mk['nama_mk'] ??
                                                                  "-",
                                                              style: const TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Color(
                                                                  0xFF101828,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 2,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  const Color(
                                                                    0xFFEFF4FF,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              "${mk['sks'] ?? 0} SKS",
                                                              style: const TextStyle(
                                                                fontSize: 11,
                                                                color: Color(
                                                                  0xFF2D62ED,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "Prodi: ${prodi['nama_prodi'] ?? '-'}",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                            0xFF475467,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .meeting_room_outlined,
                                                                size: 14,
                                                                color: Color(
                                                                  0xFF667085,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                "Kelas: ${kelas['kode_kelas'] ?? '-'}",
                                                                style: const TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Color(
                                                                    0xFF344054,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .people_outline_rounded,
                                                                size: 14,
                                                                color: Color(
                                                                  0xFF667085,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                "${mk['jumlah_mahasiswa'] ?? 0} Mhs",
                                                                style: const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Color(
                                                                    0xFF344054,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            ta['tahun_akademik'] ??
                                                                "-",
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Color(
                                                                    0xFF98A2B3,
                                                                  ),
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}