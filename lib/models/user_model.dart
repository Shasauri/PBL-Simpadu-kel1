class UserModel {
  final int id;
  final String name;
  final String username;
  final String nomorIdentitas;
  final String email;
  final int roleId;
  final String status;
  final String createdAt;
  final List<RoleModel> roles; // Berubah menjadi List dari RoleModel

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.nomorIdentitas,
    required this.email,
    required this.roleId,
    required this.status,
    required this.createdAt,
    required this.roles,
  });

  // Getter otomatis untuk mencari nama role utama (bukan 'pegawai')
  // Getter otomatis untuk mencari nama role utama dengan backup dari roleId
  String get getUtamaRole {
    // 1. Jika list roles tidak kosong, cari yang bukan 'pegawai' terlebih dahulu
    if (roles.isNotEmpty) {
      final roleUtama = roles.firstWhere(
        (r) => r.namaRole.toLowerCase() != "pegawai",
        orElse: () => roles.first, // Jika semua bernilai 'pegawai', ambil yang pertama
      );

      String name = roleUtama.namaRole.toLowerCase().replaceAll(' ', '_');
      if (name == "super_admin") return "Super Admin";
      if (name == "admin_akademik") return "Admin Akademik";
      if (name == "admin_pegawai") return "Admin Pegawai";
      if (name == "admin_mahasiswa") return "Admin Mahasiswa";
      if (name == "admin_keuangan") return "Admin Keuangan";
      if (name != "pegawai" && name.isNotEmpty) {
        // Mengubah format text biasa (misal: admin_keuangan -> Admin Keuangan) jika ada custom role baru
        return name.split('_').map((str) => str.isEmpty ? '' : '${str[0].toUpperCase()}${str.substring(1)}').join(' ');
      }
    }

    // 2. BACKUP / FALLBACK: Jika list roles kosong (sering terjadi pada data yang baru di-input secara lokal/form), 
    // gunakan angka roleId untuk mendeteksi nama aslinya secara akurat.
    switch (roleId) {
      case 1:
        return "Super Admin";
      case 2:
        return "Admin Akademik";
      case 3:
        return "Admin Pegawai";
      case 4:
        return "Admin Mahasiswa";
      case 5:
        return "Admin Keuangan";
      default:
        return "Pegawai";
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Mapping dari JSON Array 'roles' ke List<RoleModel>
    var listRoles = json['roles'] as List?;
    List<RoleModel> rolesList = listRoles != null
        ? listRoles.map((i) => RoleModel.fromJson(i)).toList()
        : [];

    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      nomorIdentitas: json['nomor_identitas'] ?? '',
      email: json['email'] ?? '',
      roleId: json['role_id'] ?? 0,
      status: json['status'] ?? 'non-aktif',
      createdAt: json['created_at'] ?? '',
      roles: rolesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'nomor_identitas': nomorIdentitas,
      'email': email,
      'role_id': roleId,
      'status': status,
      'created_at': createdAt,
      'roles': roles.map((e) => e.toJson()).toList(),
    };
  }
}

class RoleModel {
  final int idRole;
  final String namaRole;

  RoleModel({
    required this.idRole,
    required this.namaRole,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      idRole: json['id_role'] ?? 0,
      namaRole: json['nama_role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_role': idRole,
      'nama_role': namaRole,
    };
  }
}