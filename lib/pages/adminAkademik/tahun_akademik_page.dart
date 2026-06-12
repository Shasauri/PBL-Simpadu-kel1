import 'package:flutter/material.dart';
import '../../services/academic_service.dart';

class TahunAkademikPage extends StatefulWidget {
  const TahunAkademikPage({super.key});

  @override
  State<TahunAkademikPage> createState() => _TahunAkademikPageState();
}

class _TahunAkademikPageState extends State<TahunAkademikPage> {
  List<dynamic> _allTahunAkademik = [];
  List<dynamic> _filteredTahunAkademik = [];
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
    final data = await AcademicService.fetchAllTahunAkademik();
    setState(() {
      _allTahunAkademik = data;
      _filteredTahunAkademik = data;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTahunAkademik = _allTahunAkademik.where((item) {
        String name = (item['tahun_akademik'] ?? '').toString().toLowerCase();
        String id = (item['id'] ?? '').toString().toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();
    });
  }

  // ==================== 1. DIALOG TAMBAH DATA (Buat Tahun Akademik.png) ====================
  void _showCreateDialog() {
    final idController = TextEditingController();
    final namaController = TextEditingController();
    String selectedStatus = 'nonaktif'; // Default isi dropdown

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: const Text("Buat Tahun Akademik", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ID Tahun Akademik", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: idController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: "Contoh: 20261", contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                    const SizedBox(height: 14),
                    const Text("Tahun Akademik", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(hintText: "Contoh: 2026 ganjil", contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                    const SizedBox(height: 14),
                    const Text("Status", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'aktif', child: Text("Aktif")),
                        DropdownMenuItem(value: 'nonaktif', child: Text("Non-Aktif")),
                      ],
                      onChanged: (value) {
                        if (value != null) setModalState(() => selectedStatus = value);
                      },
                      decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D62ED)),
                  onPressed: () async {
                    if (idController.text.isEmpty || namaController.text.isEmpty) return;
                    Navigator.pop(context);
                    setState(() => _isLoading = true);
                    
                    bool res = await AcademicService.createTahunAkademik(
                      id: idController.text.trim(),
                      tahunAkademik: namaController.text.trim(),
                      status: selectedStatus,
                    );
                    
                    if (res) _showSuccessSnackBar("Tahun Akademik baru berhasil ditambahkan!");
                    _loadData();
                  },
                  child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==================== 2. DIALOG UBAH DATA (Ubah Tahun Akademik.png) ====================
  void _showEditDialog(Map<String, dynamic> item) {
    final namaController = TextEditingController(text: item['tahun_akademik']);
    String selectedStatus = item['status'] ?? 'nonaktif';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: const Text("Ubah Tahun Akademik", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ID: ${item['id']}", style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  const Text("Tahun Akademik", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(height: 14),
                  const Text("Status", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: const [
                      DropdownMenuItem(value: 'aktif', child: Text("Aktif")),
                      DropdownMenuItem(value: 'nonaktif', child: Text("Non-Aktif")),
                    ],
                    onChanged: (value) {
                      if (value != null) setModalState(() => selectedStatus = value);
                    },
                    decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D62ED)),
                  onPressed: () async {
                    if (namaController.text.isEmpty) return;
                    Navigator.pop(context);
                    setState(() => _isLoading = true);

                    bool res = await AcademicService.updateTahunAkademik(
                      id: item['id'],
                      tahunAkademik: namaController.text.trim(),
                      status: selectedStatus,
                    );

                    if (res) _showSuccessSnackBar("Data tahun akademik berhasil diperbarui!");
                    _loadData();
                  },
                  child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==================== 3. DIALOG KONFIRMASI STATUS (Aktif & Non-Aktif Tahun Akademik.png) ====================
  void _showToggleStatusDialog(Map<String, dynamic> item) {
    String currentStatus = item['status'] ?? 'nonaktif';
    String newStatus = currentStatus == 'aktif' ? 'nonaktif' : 'aktif';
    bool isGoingToActive = newStatus == 'aktif';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          // Menyesuaikan judul pop-up berdasarkan file Aktif/Non-Aktif Tahun Akademik.png
          title: Text(
            isGoingToActive ? "Aktifkan Tahun Akademik" : "Non-Aktifkan Tahun Akademik",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            isGoingToActive
                ? "Apakah Anda yakin ingin mengaktifkan tahun akademik ini? Mengaktifkan akan menonaktifkan tahun akademik yang lain."
                : "Apakah Anda yakin ingin menonaktifkan tahun akademik ini?",
            style: const TextStyle(fontSize: 14, color: Color(0xFF475467)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isGoingToActive ? const Color(0xFF12B76A) : const Color(0xFFD92D20),
              ),
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);

                bool res = await AcademicService.updateTahunAkademik(
                  id: item['id'],
                  tahunAkademik: item['tahun_akademik'],
                  status: newStatus,
                );

                if (res) {
                  _showSuccessSnackBar("Status tahun akademik berhasil diubah menjadi $newStatus!");
                }
                _loadData();
              },
              child: Text(isGoingToActive ? "Aktifkan" : "Non-Aktifkan", style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFF12B76A), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(8)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF344054), size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text("Tahun Akademik", style: TextStyle(color: Color(0xFF101828), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SEARCH BAR RELEVANT TO DESIGN
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari tahun akademik...",
                      hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF667085)),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D62ED), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BUTTON TAMBAH DATA (Buat Tahun Akademik TRIGGER)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D62ED),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: _showCreateDialog,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("Tambah Tahun Akademik", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Total Data: ${_filteredTahunAkademik.length}",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475467)),
                  ),
                  const SizedBox(height: 10),

                  // LIST CARD DATA TAHUN AKADEMIK
                  Expanded(
                    child: _filteredTahunAkademik.isEmpty
                        ? const Center(child: Text("Data tahun akademik tidak ditemukan.", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _filteredTahunAkademik.length,
                            itemBuilder: (context, index) {
                              final item = _filteredTahunAkademik[index];
                              bool isAktif = (item['status'] ?? '').toString().toLowerCase() == 'aktif';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFEAECF0)),
                                  boxShadow: const [BoxShadow(color: Color(0x05101828), blurRadius: 6, offset: Offset(0, 2))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("ID: ${item['id']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF98A2B3), fontSize: 12)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isAktif ? const Color(0xFFECFDF3) : const Color(0xFFFEF3F2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            isAktif ? "Aktif" : "Non-Aktif",
                                            style: TextStyle(color: isAktif ? const Color(0xFF027A48) : const Color(0xFFB42318), fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(item['tahun_akademik'] ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                                    const SizedBox(height: 16),
                                    const Divider(height: 1, color: Color(0xFFF2F4F7)),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // ACTION BUTTON: EDIT DATA
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Color(0xFFD0D5DD)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          ),
                                          onPressed: () => _showEditDialog(item),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.edit_outlined, color: Color(0xFF344054), size: 16),
                                              SizedBox(width: 4),
                                              Text("Edit Data", style: TextStyle(color: Color(0xFF344054), fontSize: 12, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // ACTION BUTTON: TOGGLE AKTIF/NON-AKTIF
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isAktif ? const Color(0xFFFEF3F2) : const Color(0xFFEFFFEC),
                                            shadowColor: Colors.transparent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          ),
                                          onPressed: () => _showToggleStatusDialog(item),
                                          child: Text(
                                            isAktif ? "Non-Aktifkan" : "Aktifkan",
                                            style: TextStyle(color: isAktif ? const Color(0xFFB42318) : const Color(0xFF027A48), fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}