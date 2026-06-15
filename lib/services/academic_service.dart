import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AcademicService {
  // Set ke server VPS yang sama dengan AuthService
  static const String baseUrl = "https://admin4e06.vps-poliban.my.id//api/akademik";

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Ambil Jumlah Mahasiswa
  static Future<int> fetchMahasiswaCount() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/mahasiswa"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.length;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  // 2. Ambil Jumlah Dosen Aktif
  static Future<int> fetchDosenCount() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/dosen"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.length;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  // 3. Ambil Data Kelas (Untuk Total Kelas & Daftar Kelas Aktif)
  static Future<List<dynamic>> fetchKelas() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/kelas"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // 4. Ambil Jumlah Mata Kuliah
  static Future<int> fetchMataKuliahCount() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/mata-kuliah"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.length;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  // 5. Ambil Tahun Akademik Aktif
  static Future<List<dynamic>> fetchTahunAkademik() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/tahun-akademik/aktif"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // 6. Ambil SEMUA data Tahun Akademik (Baik Aktif maupun Nonaktif)
  static Future<List<dynamic>> fetchAllTahunAkademik() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/tahun-akademik"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetch all tahun akademik: $e");
      return [];
    }
  }

  // 7. Update Data atau Mengubah Status Tahun Akademik
  static Future<bool> updateTahunAkademik({
    required dynamic id,
    required String tahunAkademik,
    required String status,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/tahun-akademik/$id"),
        headers: await _getHeaders(),
        body: jsonEncode({
          "id": id.toString(),
          "tahun_akademik": tahunAkademik,
          "status": status,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error update tahun akademik: $e");
      return false;
    }
  }

  // 8. Tambah Data Tahun Akademik
  static Future<bool> createTahunAkademik({
    required String id,
    required String tahunAkademik,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/tahun-akademik"),
        headers: await _getHeaders(),
        body: jsonEncode({
          "id": id,
          "tahun_akademik": tahunAkademik,
          "status": status,
        }),
      );
      // Menganggap 200 atau 201 sebagai sukses
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error create tahun akademik: $e");
      return false;
    }
  }

  // Tambahkan di dalam class AcademicService:

  // 1. Ambil Semua Data Jurusan Beserta Sub-Prodi didalamnya
  static Future<List<dynamic>> fetchJurusan() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/jurusan"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetch jurusan: $e");
      return [];
    }
  }

  // 2. Ambil Semua Data Standalone Program Studi Beserta Objek Jurusannya
  static Future<List<dynamic>> fetchProdi() async {
    try {
      // Menyesuaikan endpoint endpoint /prodis sesuai instruksi return json Anda
      final response = await http.get(
        Uri.parse("$baseUrl/prodis"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetch prodi: $e");
      return [];
    }
  }

  // Tambahkan di dalam class AcademicService:

  // 1. Tambah Data Jurusan Baru (POST)
  static Future<bool> createJurusan(String namaJurusan) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/jurusan"),
        headers: await _getHeaders(),
        body: jsonEncode({"nama_jurusan": namaJurusan}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error create jurusan: $e");
      return false;
    }
  }

  // 2. Tambah Data Program Studi Baru (POST)
  static Future<bool> createProdi(int jurusanId, String namaProdi) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/prodis"),
        headers: await _getHeaders(),
        body: jsonEncode({"jurusan_id": jurusanId, "nama_prodi": namaProdi}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error create prodi: $e");
      return false;
    }
  }

  // Tambahkan di dalam class AcademicService:

  // 1. Update Data Jurusan (PUT)
  static Future<bool> updateJurusan(int id, String namaJurusan) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/jurusan/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...await _getHeaders(),
        },
        body: jsonEncode({"nama_jurusan": namaJurusan}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error update jurusan: $e");
      return false;
    }
  }

  // 2. Update Data Program Studi (PUT)
  static Future<bool> updateProdi(
    int id,
    int jurusanId,
    String namaProdi,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/prodis/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...await _getHeaders(),
        },
        body: jsonEncode({"jurusan_id": jurusanId, "nama_prodi": namaProdi}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error update prodi: $e");
      return false;
    }
  }

  // Tambahkan di dalam class AcademicService:

  // 1. Fetch Semua Data Kelas (GET)
  static Future<List<dynamic>> fetchAllKelas() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/kelas"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetch all kelas: $e");
      return [];
    }
  }

  // 2. Fetch Detail Kelas Berdasarkan ID (GET)
  static Future<Map<String, dynamic>?> fetchDetailKelas(int idKelas) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/kelas/$idKelas"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Ambil objek "kelas" dari response
        return data['kelas'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetch detail kelas: $e");
      return null;
    }
  }

  // 3. Tambah Kelas Baru (POST)
  static Future<bool> createKelas(Map<String, dynamic> bodyData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/kelas"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...await _getHeaders(),
        },
        body: jsonEncode(bodyData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error create kelas: $e");
      return false;
    }
  }

  // 4. Ubah Data Kelas (PUT)
  static Future<bool> updateKelas(
    int idKelas,
    Map<String, dynamic> bodyData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/kelas/$idKelas"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...await _getHeaders(),
        },
        body: jsonEncode(bodyData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error update kelas: $e");
      return false;
    }
  }

  // Tambahkan di dalam class AcademicService:

  // 1. Fetch Detail Kelas & Mahasiswa Didalamnya (GET)
  static Future<Map<String, dynamic>?> fetchDetailKelolaKelas(
    int idKelas,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/kelas/$idKelas"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetch kelola kelas: $e");
      return null;
    }
  }

  // 2. Fetch List Anggota Mahasiswa di Kelas Tersebut (GET)
  static Future<List<dynamic>> fetchMahasiswaKelas(int idKelas) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/kelas/$idKelas/mahasiswa"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('data')) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print("Error fetch mahasiswa kelas: $e");
      return [];
    }
  }

  // 3. Hapus/Keluarkan Mahasiswa dari Kelas (DELETE)
  static Future<bool> deleteMahasiswaDariKelas(int idMahasiswaMk) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/mahasiswa-kelas/$idMahasiswaMk"),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error delete mahasiswa kelas: $e");
      return false;
    }
  }

  // Tambahkan di dalam class AcademicService:

  // Fetch Data Beban Mengajar Dosen (GET)
  static Future<List<dynamic>> fetchBebanMengajarDosen() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/dosen/beban-mengajar"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetch beban mengajar dosen: $e");
      return [];
    }
  }

  // Tambahkan di dalam class AcademicService:

  // 1. Ambil Tahun Akademik Aktif (GET)
  static Future<List<dynamic>> fetchTahunAkademikAktif() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/tahun-akademik/aktif"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [data];
      }
      return [];
    } catch (e) {
      print("Error fetch TA aktif: $e");
      return [];
    }
  }

  // 2. Ambil Semua Data User dengan Role Dosen (GET)
  static Future<List<dynamic>> fetchAllDosenRaw() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/dosen"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      }
      return [];
    } catch (e) {
      print("Error fetch list dosen: $e");
      return [];
    }
  }

  // 3. Ambil Mata Kuliah Berdasarkan ID Tahun Akademik (GET)
  static Future<List<dynamic>> fetchMataKuliahByTA(int taId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/mata-kuliah?tahun_akademik_id=$taId"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : (data['data'] is List ? data['data'] : []);
      }
      return [];
    } catch (e) {
      print("Error fetch mata kuliah by TA: $e");
      return [];
    }
  }

  // 4. Ambil Kelas Berdasarkan ID Tahun Akademik & Kueri Pencarian (GET)
  static Future<List<dynamic>> fetchKelasByTA(
    int taId, {
    String search = "",
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/kelas?tahun_akademik_id=$taId&search=$search"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      }
      return [];
    } catch (e) {
      print("Error fetch kelas by TA: $e");
      return [];
    }
  }

  // 5. Tambah Beban Mengajar Dosen Baru (POST ke /api/akademik/{id_kelas}/dosen)
  // Perbarui fungsi assignDosenKeKelas di dalam class AcademicService:

  static Future<Map<String, dynamic>> assignDosenKeKelas(
  int idKelas,
  Map<String, dynamic> bodyData,
) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/kelas/$idKelas/dosen"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...await _getHeaders(),
      },
      body: jsonEncode(bodyData),
    );

    print("========== DEBUG ASSIGN DOSEN ==========");
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final resData = jsonDecode(response.body);
    final message = resData['message'] as String?;

    switch (response.statusCode) {
      case 200:
      case 201:
        return {'success': true, 'message': message};
      case 400:
        return {'success': false, 'message': "Bad Request: ${message ?? 'Data tidak valid.'}"};
      case 401:
        return {'success': false, 'message': "Sesi habis, silakan login ulang."};
      case 403:
        return {'success': false, 'message': "Akses ditolak. Anda tidak punya izin."};
      case 404:
        return {'success': false, 'message': "Data tidak ditemukan di server."};
      case 409:
        return {'success': false, 'message': message ?? "Kombinasi ini sudah ada."};
      case 422:
        // Laravel biasanya return errors per-field di sini
        final errors = resData['errors'];
        final detailError = errors != null
            ? (errors as Map).values.first[0]
            : message ?? "Data tidak valid.";
        return {'success': false, 'message': "Validasi gagal: $detailError"};
      case 500:
        return {'success': false, 'message': "Terjadi kesalahan di server."};
      default:
        return {'success': false, 'message': "Error ${response.statusCode}: ${message ?? 'Terjadi kesalahan.'}"};
    }
  } catch (e) {
    print("Error assign dosen ke kelas: $e");
    return {'success': false, 'message': "Terjadi kesalahan koneksi: $e"};
  }
}

  // Tambahkan di dalam class AcademicService:

  // Fetch Seluruh List Mata Kuliah (GET)
  static Future<List<dynamic>> fetchAllMataKuliahRaw() async {
    try {
      // Menggunakan IP lokal spesifik sesuai instruksi Anda, atau bisa gunakan konstanta baseUrl Anda jika sudah dialihkan
      const String urlMataKuliah =
          "https://admin4e06.vps-poliban.my.id//api/akademik/mata-kuliah";

      final response = await http.get(
        Uri.parse(urlMataKuliah),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('data')) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print("Error fetch mata kuliah: $e");
      return [];
    }
  }

  // Tambahkan di dalam class AcademicService:

  // 1. Ambil Data Program Studi untuk Dropdown (GET)
  static Future<List<dynamic>> fetchProdis() async {
    try {
      const String urlProdi = "https://admin4e06.vps-poliban.my.id//api/akademik/prodis";
      final response = await http.get(
        Uri.parse(urlProdi),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      }
      return [];
    } catch (e) {
      print("Error fetch prodis: $e");
      return [];
    }
  }

  // 2. Kirim Data Mata Kuliah Baru (POST)
  static Future<bool> createMataKuliah(Map<String, dynamic> bodyData) async {
    try {
      const String urlStoreMK =
          "https://admin4e06.vps-poliban.my.id//api/akademik/mata-kuliah";
      final response = await http.post(
        Uri.parse(urlStoreMK),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...await _getHeaders(),
        },
        body: jsonEncode(bodyData),
      );

      print("========== DEBUG STORE MATA KULIAH ==========");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error create mata kuliah: $e");
      return false;
    }
  }

  // Tambahkan di dalam class AcademicService:

  // 1. Ambil Detail Mata Kuliah Berdasarkan ID (GET)
  static Future<Map<String, dynamic>?> fetchDetailMataKuliah(int idMk) async {
    try {
      final String urlDetail =
          "https://admin4e06.vps-poliban.my.id//api/akademik/mata-kuliah/$idMk";
      final response = await http.get(
        Uri.parse(urlDetail),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetch detail mata kuliah: $e");
      return null;
    }
  }

  // 2. Update Perubahan Data Mata Kuliah (PUT)
  static Future<bool> updateMataKuliah(
    int idMk,
    Map<String, dynamic> bodyData,
  ) async {
    try {
      final String urlUpdate =
          "https://admin4e06.vps-poliban.my.id//api/akademik/mata-kuliah/$idMk";
      final response = await http.put(
        Uri.parse(urlUpdate),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...await _getHeaders(),
        },
        body: jsonEncode(bodyData),
      );

      print("========== DEBUG UPDATE MATA KULIAH ==========");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error update mata kuliah: $e");
      return false;
    }
  }
}
