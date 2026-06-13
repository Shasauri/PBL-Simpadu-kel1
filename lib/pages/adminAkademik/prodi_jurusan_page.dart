import 'package:flutter/material.dart';
import '../../services/academic_service.dart';

class JurusanProdiPage extends StatefulWidget {
  const JurusanProdiPage({super.key});

  @override
  State<JurusanProdiPage> createState() => _JurusanProdiPageState();
}

class _JurusanProdiPageState extends State<JurusanProdiPage> {
  List<dynamic> _jurusanList = [];
  List<dynamic> _prodiList = [];
  List<dynamic> _filteredJurusan = [];
  List<dynamic> _filteredProdi = [];

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _currentTabIndex = 0; // 0 = Jurusan, 1 = Prodi

  // State untuk Sorting & Filter Jurusan
  int _sortOptionIndex = 0; // 0: A-Z, 1: Z-A, 2: Prodi Terbanyak, 3: Prodi Tersedikit
  int _filterOptionIndex = 0; // 0: Semua, 1: Punya Prodi, 2: Kosong

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_applyFiltersAndSort);
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final jurusanData = await AcademicService.fetchJurusan();
    final prodiData = await AcademicService.fetchProdi();

    setState(() {
      _jurusanList = jurusanData;
      _prodiList = prodiData;
      _filteredProdi = prodiData;
      _isLoading = false;
    });

    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    if (_currentTabIndex == 1) {
      // Logic Pencarian Prodi
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredProdi = _prodiList.where((item) {
          final prodiName = (item['nama_prodi'] ?? '').toString().toLowerCase();
          final jurusanName = (item['jurusan']?['nama_jurusan'] ?? '').toString().toLowerCase();
          return prodiName.contains(query) || jurusanName.contains(query);
        }).toList();
      });
      return;
    }

    // Logic Search, Filter, & Sort untuk Jurusan
    List<dynamic> temp = List.from(_jurusanList);
    final query = _searchController.text.toLowerCase();

    // 1. Pencarian
    if (query.isNotEmpty) {
      temp = temp.where((item) {
        final name = (item['nama_jurusan'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }

    // 2. Filter Status Kepemilikan Prodi
    if (_filterOptionIndex == 1) {
      temp = temp.where((item) => (item['prodis'] as List?)?.isNotEmpty ?? false).toList();
    } else if (_filterOptionIndex == 2) {
      temp = temp.where((item) => (item['prodis'] as List?)?.isEmpty ?? true).toList();
    }

    // 3. Sorting
    temp.sort((a, b) {
      final nameA = (a['nama_jurusan'] ?? '').toString().toLowerCase();
      final nameB = (b['nama_jurusan'] ?? '').toString().toLowerCase();
      final prodiA = (a['prodis'] as List?)?.length ?? 0;
      final prodiB = (b['prodis'] as List?)?.length ?? 0;

      switch (_sortOptionIndex) {
        case 0: return nameA.compareTo(nameB); // A-Z
        case 1: return nameB.compareTo(nameA); // Z-A
        case 2: return prodiB.compareTo(prodiA); // Terbanyak
        case 3: return prodiA.compareTo(prodiB); // Tersedikit
        default: return 0;
      }
    });

    setState(() {
      _filteredJurusan = temp;
    });
  }

  // ==================== BOTTOM SHEETS (SORT & FILTER) ====================
  void _showSortBottomSheet() {
    int tempSortIndex = _sortOptionIndex;
    final List<String> sortOptions = [
      "Nama Jurusan (A - Z)",
      "Nama Jurusan (Z - A)",
      "Total Prodi (Terbanyak)",
      "Total Prodi (Tersedikit)"
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFEAECF0), borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  const Text("Urutkan Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                  const SizedBox(height: 4),
                  const Text("Pilih kriteria untuk mengurutkan daftar jurusan.", style: TextStyle(fontSize: 13, color: Color(0xFF667085))),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEAECF0), height: 1),
                  const SizedBox(height: 16),
                  const Text("URUTKAN BERDASARKAN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF98A2B3), letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  ...List.generate(sortOptions.length, (index) {
                    bool isSelected = tempSortIndex == index;
                    return InkWell(
                      onTap: () => setModalState(() => tempSortIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEFF4FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(sortOptions[index], style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? const Color(0xFF2D62ED) : const Color(0xFF344054))),
                            if (isSelected) const Icon(Icons.check, color: Color(0xFF2D62ED), size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D62ED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                      onPressed: () {
                        setState(() { _sortOptionIndex = tempSortIndex; });
                        _applyFiltersAndSort();
                        Navigator.pop(context);
                      },
                      child: const Text("Terapkan Pengurutan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    int tempFilterIndex = _filterOptionIndex;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFEAECF0), borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  const Text("Filter Jurusan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                  const SizedBox(height: 4),
                  const Text("Saring data jurusan berdasarkan status kepemilikan prodi.", style: TextStyle(fontSize: 13, color: Color(0xFF667085))),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEAECF0), height: 1),
                  const SizedBox(height: 16),
                  const Text("STATUS KEPEMILIKAN PRODI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF98A2B3), letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  
                  _buildRadioFilterTile("Tampilkan Semua", 0, tempFilterIndex, (val) => setModalState(() => tempFilterIndex = val!)),
                  _buildRadioFilterTile("Memiliki Program Studi", 1, tempFilterIndex, (val) => setModalState(() => tempFilterIndex = val!)),
                  _buildRadioFilterTile("Belum Ada Prodi (Kosong)", 2, tempFilterIndex, (val) => setModalState(() => tempFilterIndex = val!)),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: const BorderSide(color: Color(0xFFD0D5DD))),
                            onPressed: () {
                              setState(() { _filterOptionIndex = 0; });
                              _applyFiltersAndSort();
                              Navigator.pop(context);
                            },
                            child: const Text("Reset", style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D62ED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                            onPressed: () {
                              setState(() { _filterOptionIndex = tempFilterIndex; });
                              _applyFiltersAndSort();
                              Navigator.pop(context);
                            },
                            child: const Text("Terapkan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRadioFilterTile(String title, int value, int groupValue, ValueChanged<int?> onChanged) {
    return Theme(
      data: Theme.of(context).copyWith(unselectedWidgetColor: const Color(0xFFD0D5DD)),
      child: RadioListTile<int>(
        title: Text(title, style: TextStyle(fontSize: 14, color: groupValue == value ? const Color(0xFF101828) : const Color(0xFF475467), fontWeight: groupValue == value ? FontWeight.w600 : FontWeight.w500)),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: const Color(0xFF2D62ED),
        contentPadding: EdgeInsets.zero,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      ),
    );
  }

  // ==================== DIALOG TAMBAH & EDIT JURUSAN ====================
  void _showTambahJurusanBottomSheet() {
    final nameController = TextEditingController();
    _openJurusanFormModal(title: "Data Jurusan Baru", subtitle: "Masukkan nama jurusan ke dalam sistem SIMPADU.", controller: nameController, isEdit: false);
  }

  void _showEditJurusanBottomSheet(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['nama_jurusan']);
    _openJurusanFormModal(title: "Ubah Jurusan", subtitle: "Perbarui nama jurusan di dalam sistem terpadu.", controller: nameController, isEdit: true, id: item['id']);
  }

  void _openJurusanFormModal({required String title, required String subtitle, required TextEditingController controller, required bool isEdit, int? id}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 16, right: 16, top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFEAECF0), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF667085))),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFEAECF0), height: 1),
              const SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  text: "Nama Jurusan ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF344054), fontFamily: 'Inter'),
                  children: [TextSpan(text: "*", style: TextStyle(color: Color(0xFFD92D20)))],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Masukkan nama jurusan",
                  hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2D62ED))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2D62ED))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2D62ED), width: 1.5)),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: const BorderSide(color: Color(0xFFD0D5DD))),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal", style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D62ED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                        onPressed: () async {
                          if (controller.text.trim().isEmpty) return;
                          Navigator.pop(context);
                          setState(() => _isLoading = true);

                          bool success;
                          if (isEdit) {
                            success = await AcademicService.updateJurusan(id!, controller.text.trim());
                          } else {
                            success = await AcademicService.createJurusan(controller.text.trim());
                          }

                          if (success) _showSnackBar(isEdit ? "Data jurusan berhasil diperbarui!" : "Jurusan baru berhasil ditambahkan!", Colors.green);
                          _fetchData();
                        },
                        child: Text(isEdit ? "Simpan Perubahan" : "Simpan Data", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // ==================== DIALOG TAMBAH & EDIT PRODI ====================
  void _showTambahProdiBottomSheet() {
    final prodiController = TextEditingController();
    _openProdiFormModal(title: "Data Prodi Baru", subtitle: "Masukkan nama program studi ke dalam sistem SIMPADU.", controller: prodiController, isEdit: false);
  }

  void _showEditProdiBottomSheet(Map<String, dynamic> item) {
    final prodiController = TextEditingController(text: item['nama_prodi']);
    _openProdiFormModal(title: "Ubah Program Studi", subtitle: "Perbarui data program studi di dalam sistem terpadu.", controller: prodiController, isEdit: true, id: item['id'], initialJurusanId: item['jurusan_id']);
  }

  void _openProdiFormModal({required String title, required String subtitle, required TextEditingController controller, required bool isEdit, int? id, int? initialJurusanId}) {
    int? selectedJurusanId = initialJurusanId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 16, right: 16, top: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFEAECF0), borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF667085))),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFEAECF0), height: 1),
                  const SizedBox(height: 20),
                  RichText(
                    text: const TextSpan(
                      text: "Nama Program Studi ",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF344054), fontFamily: 'Inter'),
                      children: [TextSpan(text: "*", style: TextStyle(color: Color(0xFFD92D20)))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Masukkan nama program studi",
                      hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2D62ED))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2D62ED))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2D62ED), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: const TextSpan(
                      text: "Pilih Jurusan Induk ",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF344054), fontFamily: 'Inter'),
                      children: [TextSpan(text: "*", style: TextStyle(color: Color(0xFFD92D20)))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedJurusanId,
                    hint: const Text("Pilih jurusan induk", style: TextStyle(color: Color(0xFF98A2B3), fontSize: 14)),
                    items: _jurusanList.map((jurusan) {
                      return DropdownMenuItem<int>(
                        value: jurusan['id'],
                        child: Text(jurusan['nama_jurusan'] ?? "-", style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() => selectedJurusanId = val);
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2D62ED))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2D62ED))),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: const BorderSide(color: Color(0xFFD0D5DD))),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Batal", style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D62ED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                            onPressed: () async {
                              if (controller.text.trim().isEmpty || selectedJurusanId == null) return;
                              Navigator.pop(context);
                              setState(() => _isLoading = true);

                              bool success;
                              if (isEdit) {
                                success = await AcademicService.updateProdi(id!, selectedJurusanId!, controller.text.trim());
                              } else {
                                success = await AcademicService.createProdi(selectedJurusanId!, controller.text.trim());
                              }

                              if (success) _showSnackBar(isEdit ? "Data program studi berhasil diperbarui!" : "Program studi baru berhasil ditambahkan!", Colors.green);
                              _fetchData();
                            },
                            child: Text(isEdit ? "Simpan Perubahan" : "Simpan Data", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      },
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF344054), size: 28),
            onPressed: () {
               // Aksi untuk membuka sidebar (Drawer)
            },
          ),
          title: const Text("Jurusan dan Prodi", style: TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.w700, fontSize: 18)),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF2D62ED),
                radius: 18,
                child: const Text("NA", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEAECF0), width: 1.0))
              ),
              child: TabBar(
                onTap: (index) {
                  setState(() {
                    _currentTabIndex = index;
                    _searchController.clear();
                    _applyFiltersAndSort();
                  });
                },
                indicatorColor: const Color(0xFF2D62ED),
                indicatorWeight: 3,
                labelColor: const Color(0xFF2D62ED),
                unselectedLabelColor: const Color(0xFF667085),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: const [
                  Tab(text: "Daftar Jurusan"),
                  Tab(text: "Program Studi"),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Cari nama ${_currentTabIndex == 0 ? 'jurusan' : 'program studi'}...",
                        hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF98A2B3)),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEAECF0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEAECF0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D62ED), width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Filter & Action Buttons Row
                    if (_currentTabIndex == 0)
                      Row(
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              side: const BorderSide(color: Color(0xFFEAECF0)),
                            ),
                            icon: const Icon(Icons.sort, size: 18, color: Color(0xFF667085)),
                            label: const Text("Urutkan", style: TextStyle(color: Color(0xFF344054), fontSize: 13, fontWeight: FontWeight.w600)),
                            onPressed: _showSortBottomSheet,
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              side: const BorderSide(color: Color(0xFFEAECF0)),
                            ),
                            icon: const Icon(Icons.filter_list, size: 18, color: Color(0xFF667085)),
                            label: const Text("Filter", style: TextStyle(color: Color(0xFF344054), fontSize: 13, fontWeight: FontWeight.w600)),
                            onPressed: _showFilterBottomSheet,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D62ED),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: _showTambahJurusanBottomSheet,
                              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                              label: const Text("Tambah Jurusan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D62ED),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: _showTambahProdiBottomSheet,
                              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                              label: const Text("Tambah Program Studi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Content Tab
                    Expanded(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildJurusanTabContent(),
                          _buildProdiTabContent(), // SEKARANG HALAMAN PRODI SUDAH AKTIF
                        ],
                      ),
                    ),
                    
                    // Footer Info Text
                    if (_currentTabIndex == 0 && _filteredJurusan.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text(
                          "Menampilkan ${_filteredJurusan.length} dari total ${_jurusanList.length} Jurusan",
                          style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3), fontWeight: FontWeight.w500),
                        ),
                      ),
                    if (_currentTabIndex == 1 && _filteredProdi.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text(
                          "Menampilkan ${_filteredProdi.length} dari total ${_prodiList.length} Program Studi",
                          style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3), fontWeight: FontWeight.w500),
                        ),
                      )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildJurusanTabContent() {
    if (_filteredJurusan.isEmpty) {
      return const Center(child: Text("Data jurusan tidak ditemukan.", style: TextStyle(color: Color(0xFF667085))));
    }
    return ListView.builder(
      itemCount: _filteredJurusan.length,
      itemBuilder: (context, index) {
        final item = _filteredJurusan[index];
        final List<dynamic> totalProdiList = item['prodis'] ?? [];
        final int prodiCount = totalProdiList.length;
        final bool hasProdi = prodiCount > 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(12), 
            border: Border.all(color: const Color(0xFFEAECF0))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris Judul & ID
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(color: hasProdi ? const Color(0xFF2D62ED) : const Color(0xFF98A2B3), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item['nama_jurusan'] ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                  ),
                  Text("ID: ${item['id']}", style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3), fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 16),
              // Baris Chip Prodi & Tombol Edit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: hasProdi ? const Color(0xFFEFF4FF) : const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(6)),
                    child: Text(hasProdi ? "$prodiCount Program Studi" : "Belum ada Prodi", style: TextStyle(fontSize: 12, color: hasProdi ? const Color(0xFF2D62ED) : const Color(0xFF475467), fontWeight: FontWeight.w600)),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      side: const BorderSide(color: Color(0xFFEAECF0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF2D62ED)),
                    label: const Text("Edit", style: TextStyle(fontSize: 12, color: Color(0xFF344054), fontWeight: FontWeight.w600)),
                    onPressed: () => _showEditJurusanBottomSheet(item),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildProdiTabContent() {
    if (_filteredProdi.isEmpty) {
      return const Center(child: Text("Data program studi tidak ditemukan.", style: TextStyle(color: Color(0xFF667085))));
    }
    return ListView.builder(
      itemCount: _filteredProdi.length,
      itemBuilder: (context, index) {
        final item = _filteredProdi[index];
        final String namaJurusanInduk = item['jurusan']?['nama_jurusan'] ?? "Umum";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(12), 
            border: Border.all(color: const Color(0xFFEAECF0))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(item['nama_prodi'] ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      side: const BorderSide(color: Color(0xFFEAECF0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF2D62ED)),
                    label: const Text("Edit", style: TextStyle(fontSize: 12, color: Color(0xFF344054), fontWeight: FontWeight.w600)),
                    onPressed: () => _showEditProdiBottomSheet(item),
                  )
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFF2F4F7)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.layers_outlined, color: Color(0xFF667085), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(namaJurusanInduk, style: const TextStyle(fontSize: 13, color: Color(0xFF475467), fontWeight: FontWeight.w500)),
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