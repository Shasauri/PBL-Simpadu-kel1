import 'dart:convert';
import 'package:http/http.dart' as http; // Pastikan sudah menambahkan dependensi 'http' di pubspec.yaml

// 1. Model Class untuk mapping JSON data
class UserProfile {
  final int id;
  final String name;
  final String username;
  final String nomorIdentitas;
  final String email;
  final List<int> roleIds;
  final List<String> roles;
  final String status;

  UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.nomorIdentitas,
    required this.email,
    required this.roleIds,
    required this.roles,
    required this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      nomorIdentitas: json['nomor_identitas'] ?? '',
      email: json['email'] ?? '',
      roleIds: List<int>.from(json['role_ids'] ?? []),
      roles: List<String>.from(json['roles'] ?? []),
      status: json['status'] ?? 'aktif',
    );
  }
}

// 2. Service Class untuk hit API
class ProfileService {
  // Ganti localhost ke 10.0.2.2 jika menggunakan Emulator Android
  final String baseUrl = "https://admin4e06.vps-poliban.my.id/api/akademik/users/me";

  Future<UserProfile> fetchUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Sesuaikan jika API menggunakan Bearer Token
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfile.fromJson(data);
      } else {
        throw Exception("Gagal memuat data profil: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan jaringan: $e");
    }
  }
}