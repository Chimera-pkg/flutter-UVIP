class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final String lastLoginAt;
  final String createAt;
  final String? profileFilename;
  final String? profileFilePath;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.lastLoginAt,
    required this.createAt,
    this.profileFilename,
    this.profileFilePath,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? true,
      lastLoginAt: json['last_login_at'] ?? '',
      createAt: json['created_at'] ?? json['create_at'] ?? '',
      profileFilename: json['profile_filename']?.toString(),
      profileFilePath: json['profile_file_path']?.toString(),
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
      'created_at': createAt,
      'profile_filename': profileFilename,
      'profile_file_path': profileFilePath,
    };
  }
}
