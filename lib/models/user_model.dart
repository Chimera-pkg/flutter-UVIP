class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final String lastLoginAt;
  final String createAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.lastLoginAt,
    required this.createAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? true,
      lastLoginAt: json['last_login_at'] ?? '',
      createAt: json['create_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
      'last_login_at': lastLoginAt,
      'create_at': createAt,
    };
  }
}
