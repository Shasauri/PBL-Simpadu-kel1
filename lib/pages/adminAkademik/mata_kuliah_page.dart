import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/academic_service.dart';
import 'detail_mata_kuliah_page.dart';

class MataKuliahPage extends StatefulWidget {
  const MataKuliahPage({super.key});

  @override
  State<MataKuliahPage> createState() => _MataKuliahPageState();
}

class _MataKuliahPageState extends State<MataKuliahPage> {
  List<dynamic> _mkList = [];
  List<dynamic> _filteredMkList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMataKuliah();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMataKuliah() async {
    setState(() => _isLoading = true);
    final data = await AcademicService.fetchAllMataKuliahRaw();
    setState(() {
      _mkList = data;
      _filteredMkList = data;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMkList = _mkList.where((item) {
        final namaMk = (item['nama_mk'] ?? '').toString().toLowerCase();
        final prodi = item['prodi'] ?? {};
        final namaProdi = (prodi['nama_prodi'] ?? '').toString().toLowerCase();
        final kodeMk = (item['kode_mk'] ?? '').toString().toLowerCase();
        return namaMk.contains(query) ||
            namaProdi.contains(query) ||
            kodeMk.contains(query);
      }).toList();
    });
  }

  // ==================== FORM BOTTOM SHEET: UBAH MATA KULIAH ====================
  void _openUbahMataKuliahBottomSheet(int idMk) async {
    setState(() => _isLoading = true);
    final listProdi = await AcademicService.fetchProdis();
    final detailMk = await AcademicService.fetchDetailMataKuliah(idMk);
    setState(() => _isLoading = false);

    if (detailMk == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengambil detail data mata kuliah!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final namaMkController = TextEditingController(text: detailMk['nama_mk']);
    final semesterController = TextEditingController(
      text: detailMk['semester']?.toString(),
    );
    final sksController = TextEditingController(
      text: detailMk['sks']?.toString(),
    );
    int? selectedProdiId = detailMk['prodi_id'];
    String selectedStatus = (detailMk['status'] ?? 'aktif')
        .toString()
        .toLowerCase();

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
                child: Form(
                  key: formKey,
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
                        "Ubah Mata Kuliah",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101828),
                          fontFamily: 'SansSerif'
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Program Studi",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                          fontFamily: 'SansSerif'
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
                            fontFamily: 'SansSerif'
                          ),
                        ),
                        items: listProdi.map((prodi) {
                          return DropdownMenuItem<int>(
                            value: prodi['id'],
                            child: Text(
                              prodi['nama_prodi'] ?? "-",
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'SansSerif'
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setModalState(() => selectedProdiId = val),
                        validator: (value) => value == null
                            ? 'Program studi wajib dipilih'
                            : null,
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
                      const Text(
                        "Nama Mata Kuliah",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                          fontFamily: 'SansSerif'
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: namaMkController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'SansSerif'
                        ),
                        decoration: InputDecoration(
                          hintText: "Masukkan nama mata kuliah...",
                          hintStyle: const TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 14,
                            fontFamily: 'SansSerif'
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nama mata kuliah tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Semester",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                          fontFamily: 'SansSerif'
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: semesterController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'SansSerif'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: "Contoh: 4",
                          hintStyle: const TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 14,
                            fontFamily: 'SansSerif'
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Semester wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "SKS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                          fontFamily: 'SansSerif'
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: sksController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'SansSerif'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: "Contoh: 3",
                          hintStyle: const TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 14,
                            fontFamily: 'SansSerif'
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Jumlah SKS wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Status Mata Kuliah",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                          fontFamily: 'SansSerif'
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
                              style: TextStyle(fontSize: 14, fontFamily: 'SansSerif'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "nonaktif",
                            child: Text(
                              "Non-Aktif",
                              style: TextStyle(fontSize: 14, fontFamily: 'SansSerif'),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null)
                            setModalState(() => selectedStatus = val);
                        },
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
                      const SizedBox(height: 28),
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
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              setState(() => _isLoading = true);
                              final updatePayload = {
                                "prodi_id": selectedProdiId,
                                "nama_mk": namaMkController.text.trim(),
                                "semester": int.parse(semesterController.text),
                                "sks": int.parse(sksController.text),
                                "status": selectedStatus,
                              };
                              final success =
                                  await AcademicService.updateMataKuliah(
                                    idMk,
                                    updatePayload,
                                  );
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Perubahan data mata kuliah berhasil disimpan!",
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Gagal menyimpan perubahan mata kuliah.",
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                              _loadMataKuliah();
                            }
                          },
                          child: const Text(
                            "Simpan Perubahan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SansSerif'
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== FORM BOTTOM SHEET: TAMBAH MATA KULIAH ====================
  void _openTambahMataKuliahBottomSheet() async {
    setState(() => _isLoading = true);
    final listProdi = await AcademicService.fetchProdis();
    setState(() => _isLoading = false);

    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final namaMkController = TextEditingController();
    final semesterController = TextEditingController();
    final sksController = TextEditingController();
    int? selectedProdiId;
    String selectedStatus = "aktif";

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
                child: Form(
                  key: formKey,
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
                        "Tambah Mata Kuliah",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101828),
                          fontFamily: 'SansSerif'
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Program Studi",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                          fontFamily: 'SansSerif'
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
                            fontFamily: 'SansSerif'
                          ),
                        ),
                        items: listProdi.map((prodi) {
                          return DropdownMenuItem<int>(
                            value: prodi['id'],
                            child: Text(
                              prodi['nama_prodi'] ?? "-",
                              style: const TextStyle(fontSize: 14, fontFamily: 'SansSerif'),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setModalState(() => selectedProdiId = val),
                        validator: (value) => value == null
                            ? 'Program studi wajib dipilih'
                            : null,
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
                      const Text(
                        "Nama Mata Kuliah",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                          fontFamily: 'SansSerif',
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: namaMkController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'SansSerif'),
                        decoration: InputDecoration(
                          hintText: "Masukkan nama mata kuliah...",
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
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nama mata kuliah tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Semester",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                          fontFamily: 'SansSerif'
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: semesterController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'SansSerif'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: "Contoh: 1",
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
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Semester wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "SKS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                          fontFamily: 'SansSerif'
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: sksController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'SansSerif'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: "Contoh: 3",
                          hintStyle: const TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 14,
                            fontFamily: 'SansSerif'
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Jumlah SKS wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Status Mata Kuliah",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                          fontFamily: 'SansSerif'
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
                              style: TextStyle(fontSize: 14, fontFamily: 'SansSerif'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "nonaktif",
                            child: Text(
                              "Non-Aktif",
                              style: TextStyle(fontSize: 14, fontFamily: 'SansSerif'),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null)
                            setModalState(() => selectedStatus = val);
                        },
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
                      const SizedBox(height: 28),
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
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              setState(() => _isLoading = true);
                              final bodyPayload = {
                                "prodi_id": selectedProdiId,
                                "nama_mk": namaMkController.text.trim(),
                                "semester": int.parse(semesterController.text),
                                "sks": int.parse(sksController.text),
                                "status": selectedStatus,
                              };
                              final success =
                                  await AcademicService.createMataKuliah(
                                    bodyPayload,
                                  );
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Mata kuliah baru berhasil disimpan!",
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Gagal menambahkan mata kuliah baru.",
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                              _loadMataKuliah();
                            }
                          },
                          child: const Text(
                            "Simpan Mata Kuliah",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SansSerif'
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
          child: IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: Color(0xFF344054),
              size: 24,
            ),
            onPressed: () {},
          ),
        ),
        title: const Text(
          "Mata Kuliah",
          style: TextStyle(
            color: Color(0xFF2D62ED),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'SansSerif'
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF2D62ED),
              radius: 18,
              child: const Text(
                "NA",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFamily: 'SansSerif'
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Search Bar ──
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari kode atau nama mata kuliah...",
                      hintStyle: const TextStyle(
                        color: Color(0xFF98A2B3),
                        fontSize: 14,
                        fontFamily: 'SansSerif'
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

                  // ── Filter + Mata Kuliah Baru ──
                  Row(
                    children: [
                      // Tombol Filter
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD0D5DD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
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
                              fontFamily: 'SansSerif'
                            ),
                          ),
                          onPressed: () {
                            // TODO: implementasi filter
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Tombol Mata Kuliah Baru
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D62ED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            "Mata Kuliah Baru",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'SansSerif'
                            ),
                          ),
                          onPressed: _openTambahMataKuliahBottomSheet,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── List Mata Kuliah ──
                  Expanded(
                    child: _filteredMkList.isEmpty
                        ? const Center(
                            child: Text("Mata kuliah tidak ditemukan."),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadMataKuliah,
                            child: ListView.builder(
                              itemCount: _filteredMkList.length + 1,
                              itemBuilder: (context, index) {
                                // Footer: total count
                                if (index == _filteredMkList.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4,
                                      bottom: 16,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Menampilkan ${_filteredMkList.length} dari total ${_mkList.length} Mata Kuliah",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF98A2B3),
                                          fontFamily: 'SansSerif'
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final item = _filteredMkList[index];
                                final prodi = item['prodi'] ?? {};
                                final String status =
                                    item['status'] ?? 'nonaktif';
                                final bool isAktif =
                                    status.toLowerCase() == 'aktif';
                                final int currentIdMk = item['id_mk'];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFEAECF0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ── Header: Icon + Nama + Status ──
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Icon buku
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF4FF),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.menu_book_rounded,
                                                color: Color(0xFF2D62ED),
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Nama + SKS + Semester
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['nama_mk'] ?? "-",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF101828),
                                                      fontFamily: 'SansSerif',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${item['sks'] ?? 0} SKS",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontFamily: 'SansSerif',
                                                          color: Color(
                                                            0xFF667085,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        "Semester ${item['semester'] ?? '-'}",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontFamily: 'SansSerif',
                                                          color: Color(
                                                            0xFF667085,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Badge Status
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isAktif
                                                    ? const Color(0xFFECFDF3)
                                                    : const Color(0xFFF2F4F7),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                isAktif ? "Aktif" : "Non-Aktif",
                                                style: TextStyle(
                                                  color: isAktif
                                                      ? const Color(0xFF027A48)
                                                      : const Color(0xFF667085),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'SansSerif',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // ── Program Studi Box ──
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8F9FA),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFEAECF0),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "PROGRAM STUDI",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'SansSerif',
                                                  color: Color(0xFF98A2B3),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                prodi['nama_prodi'] ?? "-",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: 'SansSerif',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF101828),
                                                ),
                                              ),
                                              Text(
                                                prodi['jurusan'] ??
                                                    prodi['nama_jurusan'] ??
                                                    "",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'SansSerif',
                                                  color: Color(0xFF667085),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),

                                        // ── Tombol Detail & Edit Data ──
                                        Row(
                                          children: [
                                            // Tombol Detail
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(
                                                    color: Color(0xFFD0D5DD),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                      ),
                                                  backgroundColor: Colors.white,
                                                ),
                                                icon: const Icon(
                                                  Icons.visibility_outlined,
                                                  size: 16,
                                                  color: Color(0xFF344054),
                                                ),
                                                label: const Text(
                                                  "Detail",
                                                  style: TextStyle(
                                                    color: Color(0xFF344054),
                                                    fontSize: 13,
                                                    fontFamily: 'SansSerif',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailMataKuliahPage(
                                                            idMk: currentIdMk,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            // Tombol Edit Data
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(
                                                    color: Color(0xFFD0D5DD),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                      ),
                                                  backgroundColor: Colors.white,
                                                ),
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 16,
                                                  color: Color(0xFF2D62ED),
                                                ),
                                                label: const Text(
                                                  "Edit Data",
                                                  style: TextStyle(
                                                    color: Color(0xFF2D62ED),
                                                    fontSize: 13,
                                                    fontFamily: 'SansSerif',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    _openUbahMataKuliahBottomSheet(
                                                      currentIdMk,
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
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
