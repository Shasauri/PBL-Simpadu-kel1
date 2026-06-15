import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Samakan Base URL agar seragam di seluruh aplikasi
  static const String baseUrl = "http://10.146.237.167:8000/api/akademik";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print("========== DEBUG LOGIN ==========");
    print("Status Code dari Server: ${response.statusCode}");
    print("Response Body Mentah: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      // Hapus paksa token lama terlebih dahulu agar tidak menumpuk/expired
      await prefs.remove('auth_token');

      // 1. Simpan Token Utama
      if (data['token'] != null) {
        await prefs.setString('auth_token', data['token']);
      }

      // 2. AKTIFKAN PENYIMPANAN DATA PROFIL KE STORAGE HP
      await prefs.setInt('admin_id', data['id'] ?? 0);
      await prefs.setString('admin_name', data['name'] ?? 'Admin Akademik');
      await prefs.setString('admin_username', data['username'] ?? '');
      await prefs.setString('admin_nip', data['nomor_identitas'] ?? '');
      await prefs.setString('admin_email', data['email'] ?? email);

      // 3. Deteksi Role untuk navigasi di UI
      List<dynamic> roles = data['roles'] ?? [];
      if (roles.contains('super_admin')) {
        await prefs.setString('admin_role', 'Super Admin');
      } else if (roles.contains('admin_akademik')) {
        await prefs.setString('admin_role', 'Admin Academic');
      } else {
        await prefs.setString('admin_role', roles.isNotEmpty ? roles.first.toString() : 'Pegawai');
      }

      print("Token Baru Berhasil Disimpan di HP: ${prefs.getString('auth_token')}");
      print("=================================");

      return data;
    } else {
      print("Login Gagal dengan Status: ${response.statusCode}");
      print("=================================");
      throw Exception('Login gagal');
    }
  }

  static Future<bool> updateSuperAdminPassword(String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      
      final response = await http.put(
        Uri.parse("$baseUrl/users/1"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "password": newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error update password: $e");
      return false;
    }
  }
}