import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TahunAkademikService {
  final String _baseUrl =
      'https://admin4e06.vps-poliban.my.id//api/akademik/tahun-akademik';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> getTahunAkademik() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Gagal memuat data (${response.statusCode})');
  }

  Future<void> tambahTahunAkademik({
    required String id,
    required String tahunAkademik,
    required String status,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: await _getHeaders(),
      body: jsonEncode({
        'id': id,
        'tahun_akademik': tahunAkademik,
        'status': status,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menambahkan tahun akademik (${response.statusCode})');
    }
  }

  Future<void> updateStatus({
    required String id,
    required String tahunAkademik,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'tahun_akademik': tahunAkademik,
        'status': status,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui status (${response.statusCode})');
    }
  }
}