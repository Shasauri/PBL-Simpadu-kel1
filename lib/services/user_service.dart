import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_kel1/models/user_model.dart'; // Sesuaikan dengan path modelmu
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  // Sesuaikan URL dengan device testing kamu (10.0.2.2 untuk emulator Android)
  static const String baseUrl =
      "https://admin4e06.vps-poliban.my.id/api/akademik/users";

  static Future<List<UserModel>> fetchUsers() async {
    try {
      // 1. Ambil token dari memori HP
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      print("Mengambil token dari HP: $token");

      // 2. Kirim request dengan menyertakan Header Authorization Bearer
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Menempelkan token ke header agar dikenali oleh Laravel/Backend
          'Authorization': 'Bearer $token',
        },
      );

      print("Status Code Server setelah kirim token: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<UserModel> users = body
            .map((dynamic item) => UserModel.fromJson(item))
            .toList();
        return users;
      } else {
        print("Response Error: ${response.body}");
        throw Exception(
          "Server menolak akses (Status: ${response.statusCode})",
        );
      }
    } catch (e) {
      print("Error Jaringan/Sistem: $e");
      throw Exception("Gagal memuat data pegawai: $e");
    }
  }

  static const String registerUrl =
      "https://admin4e06.vps-poliban.my.id/api/akademik/register";

  static Future<bool> registerUser({
    required String name,
    required String username,
    required String nomorIdentitas,
    required String email,
    required String password,
    required int roleId,
    required String status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "username": username,
          "nomor_identitas": nomorIdentitas,
          "email": email,
          "password": password,
          "role_id": roleId,
          "status": status,
        }),
      );

      print("Status Register: ${response.statusCode}");
      print("Response Body Register: ${response.body}");

      // Jika backend Laravel merespons 200 atau 201 Created, berarti sukses
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error saat registrasi pegawai: $e");
      return false;
    }
  }

  static Future<bool> updateUserStatus(int userId, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      // Alamat endpoint disesuaikan dengan ID user yang dipilih
      final String updateUrl =
          "https://admin4e06.vps-poliban.my.id/api/akademik/users/$userId";

      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // Mengirimkan field status saja sesuai kebutuhan update ringkas
        body: jsonEncode({"status": newStatus}),
      );

      print("Status Code Update Status: ${response.statusCode}");
      print("Response Body Update Status: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error saat memperbarui status pegawai: $e");
      return false;
    }
  }

  // Di dalam class UserService:

  // 1. Ambil data detail pegawai berdasarkan ID
  static Future<UserModel?> fetchUserDetail(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final String detailUrl =
          "https://admin4e06.vps-poliban.my.id/api/akademik/users/$userId";

      final response = await http.get(
        Uri.parse(detailUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UserModel.fromJson(
          data,
        ); // Pastikan UserModel kamu sudah mendukung response roles array terbaru
      }
      return null;
    } catch (e) {
      print("Error fetch detail pegawai: $e");
      return null;
    }
  }

  // 2. Kirim update data pegawai (PUT)
  static Future<bool> updateUserDetail({
    required int userId,
    required String name,
    required String username,
    required String nomorIdentitas,
    required String email,
    required int roleId,
    required String status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final String updateUrl =
          "https://admin4e06.vps-poliban.my.id/api/akademik/users/$userId";

      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "username": username,
          "nomor_identitas": nomorIdentitas,
          "email": email,
          "role_id": roleId,
          "status": status,
        }),
      );

      print("Status PUT Edit: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("Error update data pegawai: $e");
      return false;
    }
  }
}
