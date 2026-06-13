import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AcademicService {
  // Set ke server VPS yang sama dengan AuthService
  static const String baseUrl =
      "https://admin4e06.vps-poliban.my.id/api/akademik";

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
        Uri.parse("$baseUrl/tahun-akademik"),
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
      body: jsonEncode({
        "nama_jurusan": namaJurusan,
      }),
    );
    return response.statusCode == 200;
  } catch (e) {
    print("Error update jurusan: $e");
    return false;
  }
}

// 2. Update Data Program Studi (PUT)
static Future<bool> updateProdi(int id, int jurusanId, String namaProdi) async {
  try {
    final response = await http.put(
      Uri.parse("$baseUrl/prodis/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...await _getHeaders(),
      },
      body: jsonEncode({
        "jurusan_id": jurusanId,
        "nama_prodi": namaProdi,
      }),
    );
    return response.statusCode == 200;
  } catch (e) {
    print("Error update prodi: $e");
    return false;
  }
}
}
