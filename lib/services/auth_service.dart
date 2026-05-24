import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse(
        'http://10.172.145.167:8000/api/akademik/login',
      ),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    // 1. CEK REPSONSE MENTAH DARI SERVER DI SINI
    print("========== DEBUG LOGIN ==========");
    print("Status Code dari Server: ${response.statusCode}");
    print("Response Body Mentah: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Ambil SharedPreferences untuk menyimpan token ke HP
      final prefs = await SharedPreferences.getInstance();

      // Hapus paksa token lama terlebih dahulu agar tidak menumpuk/expired
      await prefs.remove('auth_token');

      // Ambil token berdasarkan struktur response API kamu.
      // Jika di JSON key-nya adalah 'token', gunakan data['token'].
      // Jika key-nya 'access_token', ubah menjadi data['access_token'].
      String tokenBaru = data['token'] ?? data['access_token'] ?? '';

      // Simpan token baru ke HP
      await prefs.setString('auth_token', tokenBaru);


      // await prefs.setString('auth_token', data['token']);
      // final user = data['user'];
      // await prefs.setInt('admin_id', user['id']);
      // await prefs.setString('admin_name', user['name']);
      // await prefs.setString('admin_email', user['email']);
      // await prefs.setString('admin_role', user['Super Admin']);
      

      // 2. CEK APAKAH TOKEN BERHASIL MASUK KE STORAGE HP
      print("Token Baru Berhasil Disimpan di HP: ${prefs.getString('auth_token')}");
      print("=================================");

      return data;
    } else {
      print("Login Gagal dengan Status: ${response.statusCode}");
      print("=================================");
      throw Exception(
        'Login gagal',
      );
    }
  }

  static Future<bool> updateSuperAdminPassword(String newPassword) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    
    // Hardcoded ID 1 sesuai instruksi spesifikasi
    const String url = "http://10.0.2.2:8000/api/akademik/users/1";

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "password": newPassword,
      }),
    );

    print("Status Code Update Password: ${response.statusCode}");
    return response.statusCode == 200;
  } catch (e) {
    print("Error update password: $e");
    return false;
  }
}
}