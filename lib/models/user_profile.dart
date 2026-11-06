class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'admin' or 'kasir'
  final String avatarUrl;
  final String phoneNumber;
  final String storeName;
  final String storeAddress;
  final String bio;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl = '',
    this.phoneNumber = '+62 812-8899-2026',
    this.storeName = 'CloudPOS • Cabang Utama',
    this.storeAddress = 'Jl. Asia Afrika No. 88, Bandung',
    this.bio = 'Founder & Head of Operations UMKM CloudPOS',
    required this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? avatarUrl,
    String? phoneNumber,
    String? storeName,
    String? storeAddress,
    String? bio,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {String email = ''}) {
    return UserProfile(
      id: (map['id'] ?? '').toString(),
      email: email.isNotEmpty ? email : (map['email'] ?? '').toString(),
      fullName: (map['full_name'] ?? 'Andriyan').toString(),
      role: (map['role'] ?? 'admin').toString(),
      avatarUrl: (map['avatar_url'] ?? '').toString(),
      phoneNumber: (map['phone_number'] ?? '+62 812-8899-2026').toString(),
      storeName: (map['store_name'] ?? 'CloudPOS • Cabang Utama').toString(),
      storeAddress:
          (map['store_address'] ?? 'Jl. Asia Afrika No. 88, Bandung').toString(),
      bio: (map['bio'] ?? 'Founder & Head of Operations UMKM CloudPOS')
          .toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'avatar_url': avatarUrl,
      'phone_number': phoneNumber,
      'store_name': storeName,
      'store_address': storeAddress,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
