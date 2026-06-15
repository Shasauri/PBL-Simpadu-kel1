import 'package:flutter/material.dart';
import '../../services/academic_service.dart';

class DetailMataKuliahPage extends StatefulWidget {
  final int idMk;

  const DetailMataKuliahPage({super.key, required this.idMk});

  @override
  State<DetailMataKuliahPage> createState() => _DetailMataKuliahPageState();
}

class _DetailMataKuliahPageState extends State<DetailMataKuliahPage> {
  Map<String, dynamic>? _detailMk;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final data = await AcademicService.fetchDetailMataKuliah(widget.idMk);
    setState(() {
      _detailMk = data;
      _isLoading = false;
    });

    if (data == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengambil detail mata kuliah!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF2D62ED),
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Mata Kuliah",
          style: TextStyle(
            color: Color(0xFF2D62ED),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'SansSerif'
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detailMk == null
          ? const Center(child: Text("Data tidak ditemukan."))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final detail = _detailMk!;
    final prodi = detail['prodi'] ?? {};
    final String status = (detail['status'] ?? 'nonaktif')
        .toString()
        .toLowerCase();
    final bool isAktif = status == 'aktif';
    final String namaProdi = prodi['nama_prodi'] ?? "-";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Icon + Nama + Badge Status ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Buku
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF2D62ED),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                // Nama + Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail['nama_mk'] ?? "-",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101828),
                          fontFamily: 'SansSerif'
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isAktif
                                  ? const Color(0xFF12B76A)
                                  : const Color(0xFF98A2B3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isAktif ? "Aktif" : "Non-Aktif",
                            style: TextStyle(
                              color: isAktif
                                  ? const Color(0xFF027A48)
                                  : const Color(0xFF667085),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFFEAECF0), thickness: 1),

            // ── Field: NAMA MATA KULIAH ──
            _buildDetailField(
              label: "NAMA MATA KULIAH",
              value: detail['nama_mk'] ?? "-",
            ),
            const Divider(color: Color(0xFFEAECF0), thickness: 1),

            // ── Field: PROGRAM STUDI ──
            _buildDetailField(label: "PROGRAM STUDI", value: "($namaProdi)"),
            const Divider(color: Color(0xFFEAECF0), thickness: 1),

            // ── Field: BOBOT (Sks) ──
            _buildDetailField(
              label: "BOBOT (Sks)",
              value: "${detail['sks'] ?? 0} SKS",
            ),
            const Divider(color: Color(0xFFEAECF0), thickness: 1),

            // ── Field: TINGKAT (Semester) ──
            _buildDetailField(
              label: "TINGKAT (Semester)",
              value: "Semester ${detail['semester'] ?? '-'}",
            ),
            const Divider(color: Color(0xFFEAECF0), thickness: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF98A2B3),
              letterSpacing: 0.5,
              fontFamily: 'SansSerif'
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
              fontFamily: 'SansSerif'
            ),
          ),
        ],
      ),
    );
  }
}
