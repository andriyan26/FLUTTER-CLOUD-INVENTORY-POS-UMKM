class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'admin' or 'kasir'
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory UserProfile.fromMap(Map<String, dynamic> map, {String email = ''}) {
    return UserProfile(
      id: (map['id'] ?? '').toString(),
      email: email.isNotEmpty ? email : (map['email'] ?? '').toString(),
      fullName: (map['full_name'] ?? 'Pengguna UMKM').toString(),
      role: (map['role'] ?? 'kasir').toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

